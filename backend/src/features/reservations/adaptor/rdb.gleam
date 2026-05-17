import gleam/list
import gleam/result
import gleam/string
import pog
import wisp
import youid/uuid

import features/reservations/application/command
import features/reservations/sql
import generated/responses.{type Reservation, Reservation}

pub fn create(db: pog.Connection) -> command.SaveReservation {
  do_create(db, _)
}

fn do_create(
  db: pog.Connection,
  info: command.ReservationInfo,
) -> Result(Reservation, String) {
  db
  |> sql.create_reservation(info.id, info.lesson_id, info.member_id)
  |> result.map(fn(_) { Reservation(id: info.id, name: "") })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save reservation"
  })
}

pub fn read_reservation_info(db: pog.Connection) -> command.ReadReservationInfo {
  do_read_reservation_info(db, _)
}

fn do_read_reservation_info(
  db: pog.Connection,
  id: uuid.Uuid,
) -> Result(command.ReservationInfo, String) {
  use returned <- result.try(
    db
    |> sql.read_reservation_info(id)
    |> result.map_error(fn(_) { "Failed to read reservation" }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  command.ReservationInfo(id: row.id, lesson_id: row.lesson_id, member_id: row.member_id)
  |> Ok()
}

pub fn delete_reservation(db: pog.Connection) -> command.DeleteReservation {
  do_delete_reservation(db, _)
}

fn do_delete_reservation(db: pog.Connection, id: uuid.Uuid) -> Result(Nil, String) {
  db
  |> sql.delete_reservation(id)
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to delete reservation"
  })
}

pub fn increment_remaining_slots(db: pog.Connection) -> command.IncrementRemainingSlots {
  do_increment_remaining_slots(db, _)
}

fn do_increment_remaining_slots(db: pog.Connection, lesson_id: uuid.Uuid) -> Result(Nil, String) {
  db
  |> sql.increment_remaining_slots(lesson_id)
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to increment remaining slots"
  })
}
