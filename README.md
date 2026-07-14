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

airbyte_platform/
├── client.py          # wrapper HTTP : auth, retry, appels génériques à l'API
├── resources.py        # fonctions idempotentes "get_or_create_X" (workspace, source, destination, connection)
├── config/
│   └── sources.yaml     # déclaration des 3 sources + destination, en données, pas en code
└── main.py              # orchestration : lit la config, authentifie, applique chaque ressource


