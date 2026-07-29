# P8 — Forecast Pipeline

Pipeline de données météo : ingestion, transformation et mise à disposition de données horaires pour trois stations (InfoClimat, Weather Underground Ichtegem, Weather Underground La Madeleine), avec déploiement cible sur AWS.

## Stack

- **Docker / Docker Compose** — orchestration locale de Postgres et dbt
- **PostgreSQL** — entrepôt de données (schémas `raw`, `seeds`, et couches dbt)
- **Airbyte (abctl)** — ingestion, configurée entièrement en code (SDK Python `airbyte-api`, pas d'UI)
- **dbt Core** — transformation, staging → intermediate → marts
- **uv** — gestion de l'environnement et des dépendances Python

## Structure du repo

```
.
├── airbyte_platform/       # configuration et orchestration Airbyte, as-code
│   ├── client.py           # client HTTP vers l'API Airbyte (auth, retry)
│   ├── resources.py        # fonctions idempotentes get_or_create_* (source, destination, connexion)
│   ├── sources.yaml        # déclaration des sources et de la destination
│   └── setup_airbyte.py    # orchestration : lit sources.yaml, applique chaque ressource, lance les syncs
├── dbt_pipeline/
│   ├── models/
│   │   ├── staging/        # 1 modèle par source brute, nettoyage/typage/renommage
│   │   ├── intermediate/   # union des sources en un schéma commun
│   │   └── marts/          # star schema final (dim_station_meteo, fct_forecast_meteo)
│   ├── macros/              # logique de transformation réutilisable par source
│   ├── seeds/               # référentiels statiques (mapping direction du vent, métadonnées stations)
│   ├── tests/                # tests dbt custom (plausibilité des mesures, cohérence inter-couches)
│   └── Dockerfile
├── docker-compose.yml
├── main.py                  # orchestration du pipeline complet (sync Airbyte → dbt run → dbt test)
└── pyproject.toml
```

## Ingestion — Airbyte

### Pourquoi abctl plutôt que Docker Compose ou PyAirbyte

Airbyte via Docker Compose est déprécié depuis août 2024. Deux alternatives ont été évaluées :

- **PyAirbyte** : librairie Python autonome, reproductible via `uv sync`, mais pas de serveur ni de synchronisation automatique — exécution statique à la demande uniquement.
- **abctl** : méthode standard en production. Synchronisation automatique, interface web de monitoring, configuration pilotée par API.

Choix retenu : **abctl**, pour la synchronisation automatique et la cohérence avec un environnement de production.

### Configuration as-code

L'interface web d'Airbyte n'est utilisée que pour le monitoring, jamais pour la configuration. Toute la configuration (sources, destination, connexions) est déclarée dans `airbyte_platform/sources.yaml` et appliquée par `setup_airbyte.py` via le SDK `airbyte-api`. Le script est idempotent : chaque exécution réinitialise le workspace (`reset_workspace`) puis recrée l'intégralité des ressources à partir du fichier de configuration, avant de déclencher les synchronisations en parallèle.

### Sources

| Source | Format | Contenu |
|---|---|---|
| `infoclimat` | JSON (fichier statique S3) | Mesures horaires de 4 stations (objet imbriqué station → tableau de mesures) + métadonnées des stations |
| `weather_ichtegem` | Excel (S3) | Mesures horaires de la station personnelle d'Ichtegem (Belgique), classeur multi-feuilles |
| `weather_la_madeleine` | Excel (S3) | Mesures horaires de la station personnelle de La Madeleine (France), classeur multi-feuilles |

Chaque source Excel est ingérée comme un fichier entier (pas feuille par feuille) : le connecteur Airbyte `source-file` ne supporte pas le filtrage par feuille (`reader_options.sheet_name` est ignoré silencieusement, quelle que soit sa syntaxe), donc toute tentative de découpage par jour aboutit à une lecture complète du classeur sous un nom trompeur. La granularité temporelle exacte (jour) n'est donc pas récupérable pour ces deux sources ; seule l'heure de la mesure est fiable — voir la section transformation.

## Transformation — dbt

### Couches

- **Staging** (`view`) : un modèle par source brute. Déballage JSON (`jsonb_each`/`jsonb_array_elements`), nettoyage des colonnes texte (regex, cast), conversion d'unités (impérial → métrique), renommage. Ajout des colonnes dérivées communes aux deux sources (`semaine`, `mois`, `annee`) et de la colonne technique `source_origine`.
- **Intermediate** (`view`) : union des sources en un schéma de colonnes strictement aligné (mêmes noms, même ordre, `NULL` explicite côté source où une colonne n'existe pas).
- **Marts** (`table`, schéma en étoile) :
  - `dim_station_meteo` — dimension des 6 stations, avec index unique sur `id_station`
  - `fct_forecast_meteo` — table de faits horaire, enrichie par jointure avec la dimension, index sur les colonnes de jointure et de filtre temporel, index unique sur `id_forecast` (clé de substitution calculée par hash)

### Points d'attention documentés dans le modèle

- La colonne `horodatage` de `fct_forecast_meteo` est fiable et précise pour InfoClimat (timestamp source réel). Pour les sources Weather Underground, seule l'heure est fiable (voir limitation du connecteur ci-dessus) : la date est reconstruite avec une valeur fixe arbitraire correspondant à la semaine réellement couverte par les données, ce qui produit un timestamp valide mais non représentatif du jour exact de la mesure.
- La clé `id_forecast` inclut la colonne technique `_airbyte_raw_id` (UUID unique par ligne ingérée) pour les sources Weather Underground, en plus de `id_station`, `horodatage` et `source_origine` — nécessaire car l'horodatage reconstruit se répète une fois par jour réel fusionné dans la même table brute.
- Les colonnes propres à une seule source (`uv_indice`, `rayonnement_solaire_wm2` côté Weather Underground ; `date_jour`, les champs de licence côté InfoClimat) sont explicitement `NULL` côté source où elles n'existent pas, plutôt qu'omises.

### Qualité

- Tests génériques (`schema.yml`) : unicité et non-nullité des clés primaires, intégrité référentielle entre `fct_forecast_meteo` et `dim_station_meteo`.
- Tests custom (`tests/`) : plausibilité physique des mesures (température, humidité), absence de date future, cohérence du nombre de lignes entre la couche intermediate et le mart correspondant.
- Documentation : chaque modèle et chaque colonne des marts sont décrits dans `schema.yml`, y compris les limites de données connues. Générée et consultable via `dbt docs generate` puis `dbt docs serve`.

## Lancer le projet

```bash
docker compose up -d
uv sync
cd airbyte_platform && uv run python setup_airbyte.py
cd ../dbt_pipeline && dbt deps && dbt run --full-refresh && dbt test
```

Ou, pour enchaîner l'ensemble :

```bash
uv run python main.py
```

## Déploiement AWS

1. **RDS PostgreSQL** — base managée remplaçant le Postgres Docker local, destination finale pour Airbyte et dbt.
2. **Secrets Manager** — stockage des identifiants RDS et autres secrets, plus de credentials en dur.
3. **Airbyte sur EC2** — instance EC2 avec abctl, reconfigurée pour synchroniser vers l'endpoint RDS.
4. **dbt sur ECS** — image Docker du projet dbt poussée sur ECR, exécutée en tâche ECS (Fargate) avec les secrets injectés depuis Secrets Manager.
5. **EventBridge** — planification récurrente de la tâche ECS, remplaçant le déclenchement manuel local.
6. **CloudWatch** — centralisation des logs Airbyte et dbt, alerte de base en cas d'échec.
