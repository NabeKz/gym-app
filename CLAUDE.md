# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

ジムアプリのモノレポ。バックエンドは **Gleam (Erlang/OTP)** + **Wisp** フレームワーク、フロントエンドは **React 19** + **TanStack Router** + **Panda CSS** で構成される。

## 開発コマンド

### バックエンド (`backend/`)

```sh
# 開発サーバー起動（ファイル変更を watch して自動再起動）
mise run dev-backend   # ルートから
# または
cd backend && mise run dev

# テスト実行
cd backend && gleam test

# ビルド
cd backend && gleam build
```

バックエンドは port **8000** で起動する。

### フロントエンド (`frontend/`)

```sh
# 開発サーバー起動
mise run dev-frontend   # ルートから
# または
cd frontend && pnpm dev

# ビルド
cd frontend && pnpm build

# フォーマット（oxfmt）
cd frontend && pnpm format

# Lint（oxlint）
cd frontend && pnpm lint
```

### コード生成（OpenAPI）

```sh
# ルートから実行（バックエンドとフロントエンド両方を生成）
mise run gen
```

これは `docs/openapi.yaml` を元に以下を生成する:
- `backend/src/generated/responses.gleam` — Gleam の型定義と JSON エンコーダー（`scripts/gen_gleam.ts` が生成）
- `frontend/src/shared/generated/openapi.gen.ts` — TypeScript の fetch クライアント（orval が生成）

**`backend/src/generated/` と `frontend/src/shared/generated/` は手動編集禁止。**

## アーキテクチャ

### API 定義ファースト

`docs/openapi.yaml` が唯一の信頼できるソース。スキーマ変更は必ずここを先に修正し、`mise run gen` でコードを再生成する。

### バックエンド構造

```
backend/src/
├── backend.gleam              # エントリーポイント（Wisp + Mist でサーバー起動）
├── app/
│   ├── router.gleam           # ルーティング（path_segments でパターンマッチ）
│   └── middleware.gleam       # 共通ミドルウェア（ログ、CSRF 保護等）
├── features/
│   └── lessons/
│       └── application/
│           ├── query.gleam    # 読み取り系ユースケース
│           └── command.gleam  # 書き込み系ユースケース
└── generated/
    └── responses.gleam        # 自動生成（編集禁止）
```

機能ごとに `features/<feature>/application/` 以下に query / command を分けて実装する。

### フロントエンド構造

```
frontend/src/
├── main.tsx                   # エントリーポイント
├── app/routes/                # TanStack Router のファイルベースルーティング
│   ├── __root.tsx             # ルートレイアウト
│   └── index.tsx              # / ルート
├── pages/                     # ページコンポーネント（ルートから呼ばれる）
│   └── lessons/
│       └── index.tsx
└── shared/generated/          # 自動生成（編集禁止）
    └── openapi.gen.ts
```

スタイリングは **Panda CSS** を使用。`styled-system/` ディレクトリ内のクラスを `panda codegen` で生成する（`pnpm build` に含まれる）。TanStack Router のルートツリーは `src/routeTree.gen.ts` に自動生成される。

### DB

バックエンドの依存に `pog`（PostgreSQL クライアント）が含まれる。DB 接続の設定は実装中。
