FROM hexpm/elixir:1.16.1-erlang-26.2.2-alpine-3.19.1 AS base

RUN MIX_HOME=/app mix do local.hex --force, local.rebar --force

RUN apk add --no-cache \
    build-base \
    git

FROM base AS build

ENV MIX_ENV=prod

WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .
RUN mix do local.rebar --force, compile, release

FROM alpine:3.19.1 AS release

RUN apk add --update --no-cache \
  libgcc \
  libstdc++ \
  ncurses-libs \
  make \
  curl

WORKDIR /app

COPY docker-entrypoint.sh ./
COPY --from=build /app/_build/prod/rel/backend_fight ./

ENTRYPOINT ["/app/docker-entrypoint.sh"]
