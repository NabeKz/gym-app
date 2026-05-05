import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import app/db
import app/handlers
import app/handlers/lessons
import app/handlers/reservations
import app/router
import features/lessons/adaptor/rdb as lessons_rdb
import features/lessons/application as lessons_app
import features/reservations/adaptor/rdb as reservations_rdb
import features/reservations/application as reservations_app

pub fn main() {
  wisp.configure_logger()

  let conn = db.start()
  let handler =
    handlers.Handlers(
      lessons: lessons.new(
        conn |> lessons_rdb.create |> lessons_app.create,
        conn |> lessons_rdb.read |> lessons_app.read,
        conn |> lessons_rdb.list |> lessons_app.list,
      ),
      reservations: reservations.new(
        conn |> reservations_rdb.create |> reservations_app.create,
      ),
    )

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
