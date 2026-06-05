import gleam/erlang/process
import gleam/list
import gleam/result
import gleam/string
import mist
import shared/env
import wisp
import wisp/wisp_mist

import app/db
import app/router
import compose
import workflows/reservation_supervisor

pub fn main() {
  wisp.configure_logger()

  let conn = db.start()
  let pepper = env.get("PASSWORD_PEPPER") |> result.unwrap("")

  let assert Ok(sup) = reservation_supervisor.start(conn)
  compose.restore_actors(conn, sup)
  let handler = compose.build(conn, pepper, sup)

  // CORS 許可オリジン。FRONTEND_ORIGIN にカンマ区切りで複数指定できる。
  // 未設定なら空リスト（クロスオリジンを一切許可しない安全側）。
  let allowed_origins =
    env.get("FRONTEND_ORIGIN")
    |> result.unwrap("")
    |> string.split(",")
    |> list.map(string.trim)
    |> list.filter(fn(o) { o != "" })

  let secret_key_base = wisp.random_string(64)
  // fly のプロキシ/ヘルスチェックは別ネットワーク名前空間から接続するため、
  // デフォルトは全インターフェース(0.0.0.0)で listen する。ローカルで localhost に
  // 絞りたい場合のみ HOST 環境変数で上書きする。
  let host = env.get("HOST") |> result.unwrap("0.0.0.0")
  let assert Ok(_) =
    handler
    |> router.handle_request(allowed_origins)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new()
    |> mist.port(8000)
    |> mist.bind(host)
    |> mist.start()

  process.sleep_forever()
}
