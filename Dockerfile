# Base images: https://hub.docker.com/r/hexpm/elixir/tags and https://hub.docker.com/_/debian?tab=tags
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.14.0-erlang-24.3.4-debian-bullseye-20210902-slim
#
ARG ELIXIR_VERSION=1.15.6
ARG OTP_VERSION=26.1.1
ARG DEBIAN_VERSION=buster-20230612-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

ARG SECRET_KEY_BASE
ARG DATABASE_PATH="/data/archie.db"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install --no-cache -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"
ENV DATABASE_PATH=${DATABASE_PATH}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-kxEfCdixUV3kGSNRfubMVL9Epqtm/m6/4g73afI2eYqu06fArQjONPjA0iLGcy9P}

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy config files and compile dependencies
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY assets assets
COPY lib lib

# compile assets
RUN mix assets.deploy

RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
VOLUME /data

RUN mix ecto.create
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

ARG DATABASE_PATH
ARG SECRET_KEY_BASE

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV MIX_ENV="prod"
ENV DATABASE_PATH=${DATABASE_PATH}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-kxEfCdixUV3kGSNRfubMVL9Epqtm/m6/4g73afI2eYqu06fArQjONPjA0iLGcy9P}

WORKDIR "/app"
RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/archie ./

USER nobody

CMD ./bin/archie eval "Archie.Release.migrate" && /app/bin/server