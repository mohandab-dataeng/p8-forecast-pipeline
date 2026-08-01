#!/bin/bash

set -e

# Création du fichier de log et son chemin
LOG_FILE="/var/log/p8-airbyte-sync.log"

# Garantit l'extinction de l'EC2 quel que soit le résultat du script
trap "echo \"\$(date): Extinction de l'EC2 (fin de script)\" >> \"$LOG_FILE\"; sudo shutdown -h now" EXIT

# Chemin exact du repo
echo "$(date): Début du script" >> "$LOG_FILE"
cd /home/ubuntu/p8-forecast-pipeline

# Lance la commande de sync airbyte en demarrant le script
echo "$(date): Lancement de la sync Airbyte" >> "$LOG_FILE"
uv run python setup_airbyte.py >> "$LOG_FILE" 2>&1

# Une fois terminé demarre le container de l'image de dbt ecs
echo "$(date): Sync Airbyte terminée, déclenchement dbt sur ECS" >> "$LOG_FILE"
aws ecs run-task \
--cluster p8-dbt-cluster \
--task-definition p8-dbt-task \
--launch-type FARGATE \
--network-configuration "awsvpcConfiguration={subnets=[subnet-05ba713e5c9e06b9b,subnet-0033f1e7b17818330,subnet-0fd7836126cb38b6c],securityGroups=[sg-088342b222245366a],assignPublicIp=ENABLED}" \
>> "$LOG_FILE" 2>&1

echo "$(date): Tâche ECS déclenchée avec succès" >> "$LOG_FILE"