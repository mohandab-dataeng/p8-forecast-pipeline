import subprocess
import sys
import time


def wait_for_airbyte():
    import requests
    for _ in range(60):
        try:
            resp = requests.get("http://localhost:8000/api/public/v1/health")
            if resp.status_code == 200:
                return True
        except requests.exceptions.ConnectionError:
            pass
        time.sleep(10)
    return False


def run_airbyte_sync():
    result = subprocess.run(
        ["uv", "run", "python", "setup_airbyte.py"],
        cwd="airbyte_platform",
    )
    return result.returncode == 0


def trigger_ecs_dbt_task():
    result = subprocess.run([
        "aws", "ecs", "run-task",
        "--cluster", "p8-dbt-cluster",
        "--task-definition", "p8-dbt-task",
        "--launch-type", "FARGATE",
        "--network-configuration",
        "awsvpcConfiguration={subnets=[SUBNET_ID],securityGroups=[SG_ID],assignPublicIp=ENABLED}",
    ])
    return result.returncode == 0


def shutdown_instance():
    subprocess.run(["sudo", "shutdown", "-h", "now"])


def main():
    if not wait_for_airbyte():
        sys.exit(1)
    if not run_airbyte_sync():
        sys.exit(1)
    if not trigger_ecs_dbt_task():
        sys.exit(1)
    shutdown_instance()


if __name__ == "__main__":
    main()