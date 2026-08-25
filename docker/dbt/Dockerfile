FROM python:3.11-slim

# git: used by `dbt debug`'s environment check and by `dbt deps`.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# dbt Core + the Postgres adapter live INSIDE this image.
RUN pip install --no-cache-dir "dbt-postgres>=1.9,<2.0"

WORKDIR /usr/app

# The project is bind-mounted at runtime (see docker-compose.yml), so code
# edits on your machine are picked up without rebuilding the image.
