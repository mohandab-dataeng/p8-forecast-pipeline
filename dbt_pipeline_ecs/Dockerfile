FROM python:3.13-slim

WORKDIR /dbt

RUN pip install --no-cache-dir dbt-postgres

COPY . .

RUN dbt deps

ENTRYPOINT ["sh", "-c", "dbt seed --target prod --profiles-dir . && dbt run --target prod --profiles-dir . && dbt test --target prod --profiles-dir ."]
