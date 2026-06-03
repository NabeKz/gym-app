# syntax=docker/dockerfile:1

# Erlang のバージョンは mise.toml を唯一のソースとし、ビルド時に必ず注入する:
#   docker build --build-arg ERLANG_VERSION=$(mise config get tools.erlang) .
# デフォルトは持たない（mise.toml 以外にバージョン値を置かないため）。
ARG ERLANG_VERSION

# ---- Build stage ----
# Erlang はベースイメージのプリコンパイル済みを使う（本プロジェクトは Erlang 29 非対応）。
# gleam / rebar は mise.toml を唯一のソースとして mise でインストールする。
FROM erlang:${ERLANG_VERSION}-alpine AS build

RUN apk add --no-cache curl git tar gcc build-base

# mise をインストール
RUN curl -fsSL https://mise.run | sh
ENV PATH="/root/.local/bin:/root/.local/share/mise/shims:$PATH"

# erlang は base image のプリコンパイル済みを使うので mise には管理させない。
# ビルドに不要な dev ツール（bun/atlas など）も除外する。これで mise が管理するのは
# gleam と rebar だけになり、exec 時に全ツールを provision しようとするのを防ぐ
# （rebar は gleam の一部 erlang 依存のビルドに必要なので残す）。
ENV MISE_DISABLE_TOOLS="erlang,bun,atlas,dotenvx,watchexec"

WORKDIR /build

# mise.toml を信頼し、gleam と rebar をインストールする
COPY mise.toml ./
RUN mise trust mise.toml && mise install gleam rebar

# 依存解決のため manifest と gleam.toml を先にコピーしてキャッシュを効かせる
COPY gleam.toml manifest.toml ./
RUN mise exec -- gleam deps download

# ソースをコピーして erlang-shipment を生成
COPY src ./src
RUN mise exec -- gleam export erlang-shipment

# ---- Runtime stage ----
# shipment は Erlang ランタイムのみ必要（gleam / mise はランタイムには不要）
FROM erlang:${ERLANG_VERSION}-alpine AS runtime

# pog/epgsql が TLS 接続に必要
RUN apk add --no-cache openssl ncurses libstdc++

WORKDIR /app

# shipment だけをコピーして軽量化
COPY --from=build /build/build/erlang-shipment ./

EXPOSE 8000

# shipment の entrypoint.sh で run する
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
