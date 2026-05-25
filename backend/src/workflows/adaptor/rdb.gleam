import gleam/list
import gleam/result
import gleam/string
import pog
import wisp
import youid/uuid

import features/lessons/sql as lessons_sql
import features/reservations/sql as reservations_sql
import generated/responses.{type Reservation, Reservation}
import workflows/create_reservation

pub fn create(conn: pog.Connection) -> create_reservation.CreateReservation {
  fn(member_id, input) {
    pog.transaction(conn, fn(tx) {
      let get_lesson = do_get_lesson(tx, _)
      let has_reservation = fn(lesson_id, mid) {
        do_has_reservation(tx, lesson_id, mid)
      }
      let save = do_save(tx, _)
      create_reservation.create(get_lesson, has_reservation, save)(
        member_id,
        input,
      )
    })
    |> result.map_error(fn(err) {
      case err {
        pog.TransactionRolledBack(msg) -> msg
        pog.TransactionQueryError(e) -> {
          wisp.log_error(string.inspect(e))
          "db error"
        }
      }
    })
  }
}

fn do_get_lesson(
  db: pog.Connection,
  id: uuid.Uuid,
) -> Result(create_reservation.LessonInfo, String) {
  use returned <- result.try(
    db
    |> lessons_sql.read_lesson_capacity(id)
    |> result.map_error(fn(e) {
      wisp.log_error(string.inspect(e))
      "Failed to read lesson"
    }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  Ok(create_reservation.LessonInfo(
    capacity: row.capacity,
    reserved_count: row.reserved_count,
  ))
}

fn do_has_reservation(
  db: pog.Connection,
  lesson_id: uuid.Uuid,
  member_id: uuid.Uuid,
) -> Result(Bool, String) {
  db
  |> reservations_sql.read_member_reservation(lesson_id, member_id)
  |> result.map(fn(returned) { !list.is_empty(returned.rows) })
  |> result.map_error(fn(e) {
    wisp.log_error(string.inspect(e))
    "Failed to check reservation"
  })
}

fn do_save(
  db: pog.Connection,
  info: create_reservation.ReservationInfo,
) -> Result(Reservation, String) {
  db
  |> reservations_sql.create_reservation(info.id, info.lesson_id, info.member_id)
  |> result.map(fn(_) { Reservation(id: info.id, name: "") })
  |> result.map_error(fn(e) {
    wisp.log_error(string.inspect(e))
    "Failed to create reservation"
  })
}
