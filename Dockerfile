FROM hexpm/elixir:1.15.7-erlang-26.2.5-debian-bookworm-20240130-slim

RUN apt-get update && apt-get install -y --no-install-recommends build-essential sqlite3 nodejs npm && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV MIX_ENV=prod
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod && mix deps.compile
COPY config config
COPY lib lib
COPY priv priv
RUN mix compile
EXPOSE 4000 43690/udp 43691/udp
CMD ["sh", "-c", "mix ecto.migrate && mix phx.server"]
