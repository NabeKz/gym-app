---
name: project-reservation-cancel
description: 予約キャンセル機能の実装状況と設計決定事項
metadata:
  type: project
---

予約キャンセル機能をフルスタックで実装済み（2026-05-29）。

**Why:** 会員が不要になった予約をキャンセルできるようにするため（requirements.md のユーザーストーリー）。

**How to apply:** 同機能に追加実装する際はこの設計に沿う。

## 設計決定

- キャンセル導線はレッスン一覧ページに統合（別ページは作らない）
- `GET /lessons` と `GET /reservations/me` を並列フェッチして frontend で merge
- 予約済みレッスンには CancelButton、未予約には ReserveButton を出し分け
- `GET /lessons` は開催前のみ返す（`starts_at > $1`、アプリ層から UTC 時刻を渡す）

## 追加した API エンドポイント

- `GET /reservations/me` — 自分の予約一覧（`{id, lessonId}` を返す）
- `DELETE /reservations/{id}` — キャンセル（204/401/403/404/409）
- `Reservation` スキーマ: `name` を廃止し `lessonId` に変更

## エラーハンドリング（cancel-button.tsx）

- 204 → 成功・再フェッチ
- 409 → 「キャンセル期限を過ぎています」
- その他 → 「キャンセルに失敗しました」
