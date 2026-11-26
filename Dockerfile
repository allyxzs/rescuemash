FROM elixir:1.18-slim AS base

FROM base AS build
RUN apt-get update && apt-get install -y --no-install-recommends build-essential ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV MIX_ENV=prod
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod && mix deps.compile
COPY lib lib
COPY priv priv
COPY scripts/build_assets.exs scripts/build_assets.exs
RUN mix compile --warnings-as-errors
# Build assets without starting runtime.exs (production secrets exist only at runtime).
RUN cp deps/phoenix/priv/static/phoenix.js priv/static/assets/phoenix.js && cp deps/phoenix_live_view/priv/static/phoenix_live_view.js priv/static/assets/phoenix_live_view.js
RUN mix release

FROM base AS runtime
WORKDIR /app
RUN groupadd --gid 10001 rescuemash && useradd --uid 10001 --gid 10001 --home-dir /app rescuemash && mkdir /data && chown rescuemash:rescuemash /data
COPY --from=build --chown=rescuemash:rescuemash /app/_build/prod/rel/rescue_mesh ./
ENV DATA_DIR=/data
USER rescuemash
EXPOSE 4000 43690/udp 43691/udp
CMD ["sh", "-c", "bin/rescue_mesh eval 'RescueMesh.Release.migrate()' && exec bin/rescue_mesh start"]
