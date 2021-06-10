# syntax = docker/dockerfile:experimental

FROM ruby:2.6.5 AS base

ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /etc/apt/trusted.gpg.d/pgdg.asc
ADD https://deb.nodesource.com/gpgkey/nodesource.gpg.key /etc/apt/trusted.gpg.d/nodesource.asc
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /etc/apt/trusted.gpg.d/yarn.asc

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    echo "--- :package: Installing system deps" \
    # Make sure apt can see trusted keys downloaded above (simpler than apt-key)
    && chmod +r /etc/apt/trusted.gpg.d/*.asc \
    # Cache apt
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
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
    # await (for waiting on dependent services)
    && cd /tmp \
    && wget -qc https://github.com/betalo-sweden/await/releases/download/v0.4.0/await-linux-amd64 \
    && install await-linux-amd64 /usr/local/bin/await \
    # watchman (for triggering code when a file changes)
    && cd /tmp \
    && wget -qc https://snapshot.debian.org/archive/debian/20200101T160433Z/pool/main/w/watchman/watchman_4.9.0-3_amd64.deb \
    && dpkg -i watchman_4.9.0-3_amd64.deb || apt-get install -yf \
    # inliner (for coverage report bundling)
    && yarn global add inliner \
    # clean up
    && rm -rf /tmp/*