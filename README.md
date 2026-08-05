# P8 — Forecast 2.0 Pipeline

Pipeline de données météorologiques de bout en bout pour GreenAndCoop, fournisseur coopératif d'électricité renouvelable dans les Hauts-de-France. Ingestion multi-source, transformation ELT en schéma en étoile, déploiement cloud automatisé — de la donnée brute à la table analytique prête pour SageMaker.

## Architecture

```
EventBridge (schedule horaire)
    │
    ▼
EC2 (Ubuntu 24.04)
    ├── systemd → run-pipeline.sh (Bash)
    │       ├── Airbyte sync (3 sources → RDS raw)
    │       └── AWS CLI → ECS run-task
    │
    ▼                           ▼
S3 (fichiers source)    ECS Fargate
                            ├── dbt seed
                            ├── dbt run (staging → intermediate → marts)
                            └── dbt test (12 contrôles qualité)
                                    │
                                    ▼
                            RDS PostgreSQL ← Secrets Manager (credentials)
                                    │
                                    ▼
                            CloudWatch (logs centralisés)
```

## Stack technique

| Couche | Outil | Rôle |
|---|---|---|
| Ingestion | Airbyte (abctl) | 3 connecteurs source, sync horaire, configuration as-code via SDK Python |
| Stockage | PostgreSQL / Amazon RDS | db.t3.micro, eu-north-1, sauvegardes automatiques |
| Transformation | dbt Core 1.12 | 3 couches (staging/intermediate/marts), 8 modèles, 12 tests |
| Compute | EC2 (Ubuntu 24.04) | Héberge Airbyte (Kubernetes via abctl), lance le pipeline |
| Orchestration | EventBridge + Bash + ECS Fargate | Schedule → boot EC2 → run-pipeline.sh → Fargate dbt |
| Conteneurisation | Docker + ECR | Image dbt versionnée, exécutée sur Fargate |
| Monitoring | CloudWatch | Logs dbt (seed/run/test) centralisés par log group |
| Sécurité | Secrets Manager + IAM | Credentials RDS chiffrés, rôles dédiés par service |
| Scripting | Bash + Python + AWS CLI | Orchestration pipeline, configuration Airbyte, déclenchement ECS |
| Versioning | Git + ECR | Code versionné, images Docker taguées |
| Environnement | uv + Docker | Gestion dépendances Python, reproductibilité locale et cloud |

## Structure du repo

```
.
├── airbyte_platform/
│   ├── client.py              # Client HTTP Airbyte (auth, retry)
│   ├── resources.py           # Fonctions idempotentes get_or_create_*
│   ├── sources.yaml           # Déclaration des sources et destination
│   └── setup_airbyte.py       # Orchestration : lecture YAML → création ressources → sync
│
├── dbt_pipeline/              # Projet dbt local (dev)
│   ├── models/
│   │   ├── staging/           # 1 modèle par source brute
│   │   ├── intermediate/      # Union des sources, schéma aligné
│   │   └── marts/             # Schéma en étoile (dimensions + faits)
│   ├── macros/                # generate_schema_name, transformations par source
│   ├── seeds/                 # Référentiels statiques (stations, directions vent)
│   ├── tests/                 # Tests custom (plausibilité, cohérence inter-couches)
│   └── profiles.yml           # Targets dev (local) et prod (RDS via env vars)
│
├── dbt_pipeline_ecs/          # Projet dbt pour déploiement ECS
│   ├── Dockerfile             # python:3.13-slim, dbt-postgres, entrypoint seed+run+test
│   ├── models/                # Identique à dbt_pipeline/models
│   ├── macros/                # Macro generate_schema_name (séparation des schémas)
│   └── profiles.yml           # Target prod uniquement (env vars → Secrets Manager)
│
├── run-pipeline.sh            # Script Bash d'orchestration EC2
├── docker-compose.yml         # Stack locale (PostgreSQL)
├── main.py                    # Orchestration locale (Airbyte sync → dbt run → dbt test)
└── pyproject.toml             # Dépendances Python (uv)
```

## Sources de données

| Source | Format | Fréquence | Particularités |
|---|---|---|---|
| InfoClimat (4 stations) | JSON imbriqué (S3) | 10 min | Stations Bergues, Hazebrouck, Armentières, Lille-Lesquin |
| Weather Underground Ichtegem | Excel multi-feuilles (S3) | Horaire | Unités impériales, 7 feuilles par classeur (1/jour) |
| Weather Underground La Madeleine | Excel multi-feuilles (S3) | Horaire | Unités impériales, 7 feuilles par classeur (1/jour) |

## Ingestion — Airbyte

### Choix d'abctl

Airbyte via Docker Compose est déprécié depuis août 2024. Deux alternatives évaluées :

- **PyAirbyte** : exécution statique à la demande, pas de synchronisation automatique.
- **abctl** : méthode standard de production. Synchronisation automatique, interface web de monitoring, API programmatique.

Choix retenu : **abctl** avec `--low-resource-mode` (obligatoire pour l'instance EC2 utilisée), combiné à une configuration entièrement as-code.

### Configuration as-code

Zéro configuration manuelle. Toute la configuration (sources, destination, connexions) est déclarée dans `sources.yaml` et appliquée par `setup_airbyte.py` via le SDK `airbyte-api`. Le script est idempotent : chaque exécution vérifie l'existence des ressources avant création, puis déclenche les synchronisations.

## Transformation — dbt

### Pipeline en 3 couches

**Staging** (views) — un modèle par source brute :
- Déballage JSON (`jsonb_each`, `jsonb_array_elements`) pour InfoClimat
- Nettoyage colonnes texte (regex, cast) pour Weather Underground
- Conversion d'unités impériales → métriques (°F→°C, mph→km/h, inHg→hPa)
- Renommage et typage uniforme
- Colonnes dérivées : `semaine`, `mois`, `annee`, `source_origine`

**Intermediate** (views) — union des sources :
- Schéma de colonnes strictement aligné (mêmes noms, même ordre)
- `NULL` explicite pour les colonnes absentes côté source

**Marts** (tables matérialisées) — schéma en étoile :
- `dim_station_meteo` — 6 stations, métadonnées complètes (réseau, coordonnées, hardware/software)
- `dim_time` — dimension temporelle (date, heure, jour de semaine, mois, année)
- `fct_forecast_meteo` — table de faits horaire, clé de substitution par hash, index sur colonnes de jointure et filtres temporels

### Macro generate_schema_name

Surcharge de la macro dbt par défaut pour produire des schémas PostgreSQL séparés (`staging`, `intermediate`, `marts`) au lieu de la concaténation `target_schema + custom_schema`.

### Contrôle qualité

**12 tests automatisés :**

| Catégorie | Tests | Nombre |
|---|---|---|
| Unicité | Clés primaires des 3 tables marts | 3 |
| Non-null | Clés primaires + clés étrangères | 4 |
| Intégrité référentielle | fct_forecast_meteo → dim_station_meteo | 1 |
| Plausibilité métier | Température, humidité, dates, volumétrie | 4 |

Résultat : **12/12 PASS — taux d'erreur 0%**.

## Déploiement AWS

### Services utilisés

| Service | Rôle | Configuration |
|---|---|---|
| RDS PostgreSQL | Base de données managée | db.t3.micro, eu-north-1, backups auto 7 jours |
| EC2 | Héberge Airbyte (abctl/Kubernetes) | Ubuntu 24.04, 30 GB gp3, rôle IAM dédié |
| ECR | Registre d'images Docker | Image `p8-dbt-ecs:latest` |
| ECS Fargate | Exécution dbt (seed + run + test) | 0.5 vCPU, 1 GB, secrets injectés |
| Secrets Manager | Credentials RDS | 3 clés : POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB |
| EventBridge | Planification horaire | Schedule → EC2 StartInstances |
| CloudWatch | Logs centralisés | Log group `/ecs/p8-dbt-task` |
| IAM | Contrôle d'accès | Rôles dédiés : ecsTaskExecutionRole, p8-schedule-ec2-role, p8-ecs-torun-ec2 |

### Flux d'orchestration

```
EventBridge (rate 1h)
    → StartInstances (EC2)
        → systemd boot → run-pipeline.sh
            → sleep 120s (attente pods Kubernetes/Airbyte)
            → uv run python setup_airbyte.py (sync 3 sources → RDS)
            → aws ecs run-task (Fargate dbt seed/run/test)
            → succès : shutdown now
            → échec : shutdown +10 (fenêtre de debug SSH)
```

### Gestion des erreurs (run-pipeline.sh)

Le script Bash utilise des tests conditionnels (`if !`) sur chaque étape critique. En cas d'échec, il log l'erreur, planifie un shutdown dans 10 minutes (fenêtre de debug), et sort. En cas de succès complet, shutdown immédiat pour maîtriser les coûts.

### Sécurité

- Credentials RDS stockés dans Secrets Manager, injectés dans la task ECS via `valueFrom`
- Variables d'environnement pour les paramètres non sensibles (host, port)
- Rôles IAM dédiés par service (ECS execution, EC2, EventBridge scheduler)
- Aucun credential en dur dans le code ou les fichiers de configuration

## Performances

| Métrique | Valeur |
|---|---|
| Sync Airbyte (3 sources) | ~5 min |
| dbt run (8 modèles) | ~2 sec |
| dbt test (12 tests) | ~1 sec |
| Fréquence de rafraîchissement | 1h |
| Délai total de mise à disposition | < 10 min |

## Lancer le projet

### Local (développement)

```bash
docker compose up -d
uv sync
cd airbyte_platform && uv run python setup_airbyte.py
cd ../dbt_pipeline && dbt deps && dbt run --full-refresh && dbt test
```

Ou en une commande :

```bash
uv run python main.py
```

### Production (AWS)

Le pipeline s'exécute automatiquement via EventBridge. Pour un déclenchement manuel :

```bash
# Depuis l'EC2
bash ~/p8-forecast-pipeline/run-pipeline.sh

# Ou déclencher dbt seul depuis CloudShell
aws ecs run-task \
  --cluster p8-dbt-cluster \
  --task-definition p8-dbt-task \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[...],securityGroups=[...],assignPublicIp=ENABLED}" \
  --region eu-north-1
```

## Points d'attention

- `abctl --low-resource-mode` est obligatoire pour l'instance EC2 utilisée (contrainte mémoire Kubernetes)
- Le connecteur Airbyte `source-file` ignore `reader_options.sheet_name` sur les fichiers Excel : l'ingestion traite le classeur entier
- La date des mesures Weather Underground est reconstruite avec une valeur fixe par semaine (seule l'heure est fiable)
- ECS cache les images Docker par tag : un `register-task-definition` est nécessaire après chaque push pour forcer le re-pull
- Au boot EC2, Airbyte (Kubernetes) met ~2 min à devenir opérationnel : le script inclut un délai d'attente