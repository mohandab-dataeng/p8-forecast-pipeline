# Déploiement Airbyte sur EC2 — P8 Forecast Pipeline

Ce document décrit le déploiement d'Airbyte sur AWS EC2, l'automatisation du cycle de synchronisation, et son enchaînement avec la tâche dbt sur ECS.

## Vue d'ensemble

```
EventBridge (planning)
    → démarre l'instance EC2
        → systemd lance main.py au boot
            → attend qu'Airbyte soit prêt
            → lance la synchronisation (setup_airbyte.py)
            → déclenche la tâche ECS Fargate (dbt run + dbt test)
            → éteint l'instance EC2
```

RDS PostgreSQL reste actif en continu (Free Tier, coût nul à ce niveau d'usage) ; seule l'instance EC2 est démarrée/arrêtée à la demande pour limiter les coûts, Airbyte via `abctl` n'étant pas serverless.

## Infrastructure

| Ressource | Détail |
|---|---|
| Instance EC2 | `p8-airbyte-server`, `m7i-flex.large` (2 vCPU / 8 Go), Ubuntu 24.04 LTS, 30 Go gp3 |
| RDS | `p8-meteoforecast-server`, PostgreSQL, `db.t3.micro`, Free Tier |
| Security group EC2 | SSH (22) + Airbyte UI (8000), restreints à l'IP de développement |
| Security group RDS | Autorise le security group de l'EC2 sur le port 5432 |

## Installation d'Airbyte

Airbyte est installé via `abctl`, seule méthode officiellement maintenue (Docker Compose déprécié depuis août 2024).

```bash
curl -LsfS https://get.airbyte.com | bash -
abctl local install --low-resource-mode
```

### `--low-resource-mode`

Sans ce flag, Kubernetes (le cluster `kind` créé par `abctl`) exige une réservation de ressources fixe avant de lancer le pod de réplication d'un sync (~4 Gi RAM / 2 CPU cumulés pour les conteneurs source + destination + orchestrateur), quel que soit le volume réel de données transférées. Sur un `m7i-flex.large`, cette réservation échoue systématiquement (`ResourceConstraintException`) même pour des fichiers de quelques centaines de Ko.

`--low-resource-mode` met ces requêtes de ressources à 0 : Kubernetes lance les pods sans garantie minimale préalable, consommation réelle seulement. Comportement non recommandé pour de la production à fort volume, mais adapté à ce projet (trois fichiers sources, quelques milliers de lignes).

## Configuration as-code

Aucune configuration n'est faite via l'interface web. Le repo est cloné directement sur l'instance et piloté par `uv` :

```bash
git clone <repo-url>
curl -LsSf https://astral.sh/uv/install.sh | sh
cd p8-forecast-pipeline
uv sync
```

Toutes les valeurs d'environnement (host RDS, credentials, host Airbyte) sont externalisées en variables d'environnement (`.env`, non commité), jamais en dur dans le code — y compris l'URL de l'API Airbyte (`AIRBYTE_URL`), pour que le même code fonctionne sans modification que le script s'exécute sur l'EC2 (`localhost`) ou ailleurs.

## Automatisation du cycle

### Script d'orchestration (`main.py`)

Exécuté au démarrage de l'instance, dans l'ordre :

1. Attend qu'Airbyte réponde sur `/api/public/v1/health`
2. Lance `setup_airbyte.py` (création idempotente des ressources Airbyte + déclenchement des syncs)
3. Déclenche la tâche ECS Fargate dbt (`aws ecs run-task`)
4. Éteint l'instance (`shutdown -h now`)

### Service systemd

```ini
# /etc/systemd/system/airbyte-sync.service
[Unit]
Description=Airbyte sync then trigger dbt on ECS then shutdown
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
WorkingDirectory=/home/ubuntu/p8-forecast-pipeline
ExecStart=/usr/bin/env uv run python main.py
User=ubuntu

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable airbyte-sync.service
```

Le service se déclenche automatiquement à chaque démarrage de l'instance (`Type=oneshot` : une exécution unique par boot, pas de boucle).

### Déclenchement planifié — EventBridge

Une règle EventBridge (`p8-airbyte-sync-schedule`) démarre l'instance EC2 selon un planning (rate-based ou cron), via un appel `EC2 StartInstances`. Le rôle IAM associé à la règle nécessite la permission `ec2:StartInstances` ; l'instance elle-même nécessite un rôle IAM avec `ecs:RunTask` pour déclencher la tâche dbt en fin de cycle.

## Historique des blocages rencontrés

Documenté ici pour référence — chaque point a nécessité une vérification en doc officielle avant résolution, pas de correctif par supposition.

| Symptôme | Cause | Résolution |
|---|---|---|
| `sheet_name` ignoré par le connecteur `source-file` | Non supporté par le connecteur (confirmé par le code source et la doc officielle) | Ingestion du fichier Excel entier par source, granularité jour perdue pour les sources Weather Underground |
| `502 Bad Gateway` sur `/connections` | Disque EBS saturé (100 %), empêchant Kubernetes de créer de nouveaux conteneurs | Extension du volume à 30 Go (`growpart` + `resize2fs`) |
| UI Airbyte : `Minified React error #185` | Bug connu, non résolu, lié à l'authentification (issues GitHub airbytehq/airbyte) | Contournement : `auth.enabled: false` en attendant un correctif officiel |
| `401 Unauthorized` en cours de sync | Token API expirant après 900 s, jamais rafraîchi par le script d'attente | Ré-authentification automatique sur `401` dans `client.py` |
| `ResourceConstraintException` sur le pod de réplication | Requêtes de ressources par défaut (~4 Gi) disproportionnées au volume réel | `abctl local install --low-resource-mode` |

## Nettoyage en fin de projet

```bash
# EC2 : Stop (jamais Terminate avant la fin définitive du projet)
# RDS : Stop temporarily (redémarre automatiquement après 7 jours si non relancé)
```

Surveiller l'onglet facturation AWS et libérer toute ressource (EC2, RDS, ECR, Elastic IP le cas échéant) à l'issue du projet.