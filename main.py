import subprocess
import sys


def run_airbyte_sync():
    result = subprocess.run(
        ["uv", "run", "python", "setup_airbyte.py"],
        cwd="airbyte_platform",
    )
    return result.returncode == 0


def run_dbt_run():
    result = subprocess.run(
        ["dbt", "run", "--full-refresh"],
        cwd="dbt_pipeline",
    )
    return result.returncode == 0


def run_dbt_test():
    result = subprocess.run(
        ["dbt", "test"],
        cwd="dbt_pipeline",
    )
    return result.returncode == 0


def main():
    if not run_airbyte_sync():
        sys.exit(1)

    if not run_dbt_run():
        sys.exit(1)

    if not run_dbt_test():
        sys.exit(1)


if __name__ == "__main__":
    main()
