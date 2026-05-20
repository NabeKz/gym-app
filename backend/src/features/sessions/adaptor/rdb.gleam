import features/sessions/application/command
import features/sessions/sql
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import wisp
import youid/uuid

fn do_save_session(
  db: pog.Connection,
  id: uuid.Uuid,
  member_id: uuid.Uuid,
  token: String,
  created_at: timestamp.Timestamp,
) -> Result(String, String) {
  db
  |> sql.create_session(id, member_id, token, created_at)
  |> result.map(fn(_) { token })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save session"
  })
}

pub fn save_session(db: pog.Connection) -> command.SaveSession {
  fn(id, member_id, token, created_at) {
    do_save_session(db, id, member_id, token, created_at)
  }
}

fn do_delete_session(
  db: pog.Connection,
  token: String,
) -> Result(Nil, String) {
  db
  |> sql.delete_session(token)
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to delete session"
  })
}

pub fn delete_session(db: pog.Connection) -> command.DeleteSession {
  do_delete_session(db, _)
}
