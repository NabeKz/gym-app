import generated/responses
import gleam/string
import pog
import wisp

import features/reservations/application/command
import features/reservations/sql

pub fn create(db: pog.Connection) -> command.SaveReservation {
  do_create(db, _)
}

fn do_create(
  db: pog.Connection,
  reservation: responses.Reservation,
) -> Result(responses.Reservation, String) {
  case db |> sql.create_reservation(reservation.id) {
    Ok(_) -> reservation |> Ok()
    Error(err) -> {
      wisp.log_error(string.inspect(err))
      "Failed to save reservation" |> Error()
    }
  }
}
