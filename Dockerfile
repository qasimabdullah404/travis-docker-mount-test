# syntax = docker/dockerfile:experimental

FROM node:14.15.3 AS base

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    echo "--- :package: Installing system deps" \
    # Install all the things
    && apt-get update \
    && apt-get install -y postgresql-client-12 nodejs yarn wkhtmltopdf \
    # clean up
    && rm -rf /tmp/*