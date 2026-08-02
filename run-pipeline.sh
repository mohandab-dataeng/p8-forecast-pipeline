#!/bin/bash

LOG_FILE="/var/log/p8-airbyte-sync.log"

echo "$(date): Début du script" >> "$LOG_FILE"
cd /home/ubuntu/p8-forecast-pipeline/airbyte_platform

echo "$(date): Lancement de la sync Airbyte" >> "$LOG_FILE"
echo "$(date): Attente Airbyte (120s)..." >> "$LOG_FILE"
sleep 120
if ! /home/ubuntu/.local/bin/uv run python setup_airbyte.py >> "$LOG_FILE" 2>&1; then
  echo "$(date): ERREUR sync Airbyte — extinction dans 10 min" >> "$LOG_FILE"
  sudo shutdown +10
  exit 1
fi

echo "$(date): Sync Airbyte terminée, déclenchement dbt sur ECS" >> "$LOG_FILE"
if ! /home/ubuntu/.local/bin/aws ecs run-task \
  --cluster p8-dbt-cluster \
  --task-definition p8-dbt-task \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-05ba713e5c9e06b9b,subnet-0033f1e7b17818330,subnet-0fd7836126cb38b6c],securityGroups=[sg-088342b222245366a],assignPublicIp=ENABLED}" \
  >> "$LOG_FILE" 2>&1; then
  echo "$(date): ERREUR run-task ECS — extinction dans 10 min" >> "$LOG_FILE"
  sudo shutdown +10
  exit 1
fi

echo "$(date): Tâche ECS déclenchée avec succès" >> "$LOG_FILE"
echo "$(date): Pipeline OK — extinction immédiate" >> "$LOG_FILE"
sudo shutdown now