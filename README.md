# Projet 08 - Pipeline de forecast meteo vers aws

## Description
Le projet constiste en pipeline ETL afin d'extraire des données meteo, de les traiter , et de les charger vers le cloud amazon aws.
Les outils employés sont docker, airbyte, et dbt pour la partie dev. Pour la parie prod mous deploieront la maquette vers aws une fois que la maquette sera totalement operationnelle.

## Stack complet

## Journal 
1. docker (deja installer)
2. container postgres via docker-compose directement
3. Airbyte via abctl et septup-airbyte.py


## Pourquoi ce choix d'installation Airbyte ?

Airbyte via Docker Compose est déprécié depuis août 2024 et n'est plus supporté.
Deux options ont été évaluées :

- PyAirbyte : librairie Python autonome, tout dans le repo, reproductible avec uv sync.
  Mais pas de serveur, pas de sync automatique, pas d'interface web. Exécution statique à la demande.

- abctl : méthode standard utilisée aujourd'hui en production et en entreprise.
  Sync automatique toutes les 30 minutes, interface web pour le monitoring,
  configuration reproductible via le SDK Python airbyte-api (setup_airbyte.py).

Choix retenu : abctl, pour la synchronisation automatique et la cohérence avec un environnement de production.

## Airbyte

Il est installe mais on ce sert pas de l'interfae graphique. On script un setup en python  qui realise le setting de connexion  automatiquement. L'utilisateur devra installer abctl avant de lancer le docker compose. 

A. Plateforme faite manuelement pour controle total

airbyte_platform/
├── client.py          # wrapper HTTP : auth, retry, appels génériques à l'API
├── resources.py        # fonctions idempotentes "get_or_create_X" (workspace, source, destination, connection)
├── config/
│   └── sources.yaml     # déclaration des 3 sources + destination, en données, pas en code
└── main.py              # orchestration : lit la config, authentifie, applique chaque ressource

B. 
 
{'data': 
[{'workspaceId': '609e99f7-426d-4525-bff8-d384cf57257e', 
  'name': 'Default Workspace', 
  'dataResidency': '', 
  'notifications': {}}], 
  'previous': '', 
  'next': 'http://localhost:8001/api/public/v1/workspaces?includeDeleted=false&limit=20&offset=20'}

C. Ajout d'une API en direct (paramètres selectionnés)

  Sur open meteo on conserve les parametres present uniquement dans les autres sources. Cela permet à la source 1) reduire la quantité importée, 2) reduire le traitement dans par dbt

1. temperature_2m → température à 2m du sol (°C) — présent dans InfoClimat et WU
2. relative_humidity_2m → humidité relative (%) — présent dans les deux
3. dew_point_2m → point de rosée (°C) — présent dans les deux
4. surface_pressure → pression atmosphérique (hPa) — présent dans les deux
5. wind_speed_10m → vitesse du vent à 10m (km/h) — présent dans les deux
6. wind_direction_10m → direction du vent (°) — présent dans les deux
7. wind_gusts_10m → rafales (km/h) — présent dans les deux
8. precipitation → précipitations (mm) — présent dans les deux