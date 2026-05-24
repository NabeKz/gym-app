import gleam/erlang/process
import gleam/result
import mist
import shared/env
import wisp
import wisp/wisp_mist

import app/db
import app/handlers
import app/handlers/auth
import app/handlers/lessons
import app/handlers/reservations
import app/router
import features/lessons/adaptor/rdb as lessons_rdb
import features/lessons/application as lessons_app
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/reservations/adaptor/rdb as reservations_rdb
import features/reservations/application as reservations_app
import features/sessions/adaptor/rdb as sessions_rdb
import features/sessions/application as sessions_app

pub fn main() {
  wisp.configure_logger()

  let conn = db.start()
  let pepper = env.get("PASSWORD_PEPPER") |> result.unwrap("")

  let handler =
    handlers.Handlers(
      auth: auth.new(
        members_app.signup(
          members_rdb.save(conn),
          members_rdb.find_by_email(conn),
          pepper,
        ),
        sessions_app.login(
          members_rdb.find_by_email(conn),
          sessions_rdb.save_session(conn),
          pepper,
        ),
        sessions_app.logout(sessions_rdb.delete_session(conn)),
      ),
      lessons: lessons.new(
        conn |> lessons_rdb.create |> lessons_app.create,
        conn |> lessons_rdb.read |> lessons_app.read,
        conn |> lessons_rdb.list |> lessons_app.list,
      ),
      reservations: reservations.new(
        sessions_rdb.find_member_id_by_token(conn),
        reservations_app.create(
          reservations_rdb.create(conn),
        ),
        reservations_app.cancel(
          reservations_rdb.read_reservation_info(conn),
          reservations_rdb.delete_reservation(conn),
          lessons_rdb.read(conn),
        ),
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
