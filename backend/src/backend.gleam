import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import app/db
import app/handlers
import app/handlers/lessons
import app/router
import features/lessons/adaptor/rdb
import features/lessons/application

pub fn main() {
  wisp.configure_logger()

  let conn = db.start()
  let handler =
    handlers.Handlers(lessons: lessons.new(
      conn |> rdb.create |> application.create,
      conn |> rdb.read |> application.read,
      conn |> rdb.list |> application.list,
    ))

  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handler
    |> router.handle_request()
    |> wisp_mist.handler(secret_key_base)
    |> mist.new()
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}
