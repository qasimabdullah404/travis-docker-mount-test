# syntax = docker/dockerfile:experimental

FROM ruby:2.6.5 AS base

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    echo "--- :package: Installing system deps" \
    # Postgres apt sources
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    # Node apt sources
    && echo "deb http://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
    # Yarn apt sources
    && echo "deb http://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    # Install all the things
    && apt-get update \
    && apt-get install -y postgresql-client-12 nodejs yarn wkhtmltopdf \
    # Upgrade rubygems and bundler
    && gem update --system \
    && gem install bundler -v '< 2.0' \
    && gem install bundler \
    # clean up
    && rm -rf /tmp/*