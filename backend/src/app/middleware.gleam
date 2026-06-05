import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/list
import wisp

pub fn middleware(
  req: wisp.Request,
  allowed_origins: List(String),
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  // プリフライトを先に捌き、通常レスポンスには CORS ヘッダを付与する。
  // OPTIONS は CSRF 保護の前に処理する。
  use <- cors(req, allowed_origins)
  use req <- wisp.csrf_known_header_protection(req)

  handle_request(req)
}

/// 許可オリジンからのリクエストにのみ CORS ヘッダを付ける。
/// Signed クッキーでの認証のため credentials を許可し、Allow-Origin は
/// ワイルドカードではなくリクエストの Origin をエコーする。
fn cors(
  req: wisp.Request,
  allowed_origins: List(String),
  next: fn() -> wisp.Response,
) -> wisp.Response {
  let origin = request.get_header(req, "origin")
  let allowed = case origin {
    Ok(o) -> list.contains(allowed_origins, o)
    Error(_) -> False
  }

  case req.method, allowed, origin {
    // 許可オリジンからのプリフライト
    http.Options, True, Ok(o) -> wisp.response(204) |> set_cors_headers(o)
    // それ以外のプリフライトは CORS ヘッダなしで終了（ブラウザが弾く）
    http.Options, _, _ -> wisp.response(204)
    // 許可オリジンからの通常リクエスト
    _, True, Ok(o) -> next() |> set_cors_headers(o)
    // 非許可・Origin なし（同一オリジン等）はそのまま
    _, _, _ -> next()
  }
}

fn set_cors_headers(res: wisp.Response, origin: String) -> wisp.Response {
  res
  |> response.set_header("access-control-allow-origin", origin)
  |> response.set_header("vary", "origin")
  |> response.set_header("access-control-allow-credentials", "true")
  |> response.set_header("access-control-allow-methods", "GET, POST, DELETE, OPTIONS")
  |> response.set_header("access-control-allow-headers", "content-type")
}
