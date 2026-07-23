# ----- Pipeline Airbyte -----

import os
import yaml
import pandas as pd

# --- Recuperation de la classe et de toutes les fonctions crées dans resources.py ---

from client import AirbyteClient
from resources import (
    get_workspace_id,
    get_source_definition_id,
    get_destination_definition_id,
    get_or_create_source,
    get_or_create_destination,
    get_or_create_connection,
    trigger_sync,
    wait_for_sync,
    reset_workspace,
)
 
# --- Lit la configuration déclarative du yml ---

with open("./sources.yaml") as f:
    config = yaml.safe_load(f) # dict

sources = config["sources"]
destination = config["destination"]
source_connector = config["source_connector"]

# --- Recupere la structure du fichier excel ---

for file in config["excel_files"]:
    for feuille in pd.ExcelFile(file["url"]).sheet_names:   # (1) quelle clé pour l'URL ?
        nom = f"{file['name']}_{feuille}"                     # (2) quelle clé pour le nom ?
        sources.append({                                           # (3) quelle méthode pour ajouter à une liste ?
            "name": nom,
            "config": {
                "url": file["url"],
                "format": "excel",
                "provider": {"storage": "HTTPS"},
                "reader_options": f'{{"sheet_name": "{feuille}"}}',  # (4) quelle variable = le nom de feuille ?
                "dataset_name": nom,
            },
        })

# --- Connexion à Airbyte ---

client = AirbyteClient()
workspace_id = get_workspace_id(client)

# --- Reset après chaque run ---

reset_workspace(client, workspace_id)

# --- Récupération des ids de connecteurs ---

source_def_id = get_source_definition_id(client, workspace_id, source_connector)
dest_def_id = get_destination_definition_id(client, workspace_id, destination["connector"])

print("workspace:", workspace_id)
print("connecteur source:", source_def_id)
print("connecteur destination:", dest_def_id)

# --- Création des sources ---

source_ids = {}

for src in sources:
    source_id = get_or_create_source(
        client,
        workspace_id,
        src["name"],
        source_def_id,
        src["config"],
    )
    source_ids[src["name"]] = source_id
    print("source:", src["name"], "→", source_id)

# --- Création de la destination Postgres ---

destination_config = {
    "host": "p8-postgres",
    "port": 5432,
    "database": os.environ["POSTGRES_DB"],
    "username": os.environ["POSTGRES_USER"],
    "password": os.environ["POSTGRES_PASSWORD"], 
    "schema": destination["schema"],
}

destination_id = get_or_create_destination(
    client,
    workspace_id,
    destination["name"],
    dest_def_id,
    destination_config,
)
print("destination:", destination["name"], "→", destination_id)

# --- Boucle 1 : créer connexions + lancer les syncs (sans attendre) ---

jobs = []
for src in sources:
    name = src["name"]
    connection_id = get_or_create_connection(
        client,
        workspace_id,
        source_ids[name],
        destination_id,
        f"{name}_to_raw",
    )
    job = trigger_sync(client, connection_id)
    jobs.append(job["jobId"])                
    print("sync lancé:", f"{name}_to_raw")

# --- Boucle 2 : attendre la fin de TOUS les syncs ---

for job_id in jobs:
    wait_for_sync(client, job_id)