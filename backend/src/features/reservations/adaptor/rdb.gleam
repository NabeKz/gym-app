import generated/responses
import gleam/result
import gleam/string
import pog
import wisp

import features/reservations/application/command
import features/reservations/sql

pub fn create(
  db: pog.Connection,
  reservation: responses.Reservation,
) -> command.CreateAdaptor {
  fn(item) {
    db
    |> sql.create_reservation(reservation.id)
    |> result.map(fn(_) { item })
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to save reservation"
    })
  }
}
