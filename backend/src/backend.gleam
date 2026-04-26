import app/db
import app/handlers
import app/router
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let conn = db.start()
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handlers.new(conn)
    |> router.handle_request()
    |> wisp_mist.handler(secret_key_base)
    |> mist.new()
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}
