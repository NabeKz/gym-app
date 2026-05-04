import features/reservations/application
import gleam/json
import wisp.{type Request, type Response}

import app/handlers/error_responses
import app/handlers/validation

pub type ReservationHandler {
  ReservationHandler(
    // TODO: add handler fields
    // create: fn(Request) -> Response,
    // read: fn(String) -> Response,
    // list: fn(Request) -> Response,
  )
}

// TODO: implement handler functions
// fn create(create_fn: application.CreateReservation, req: Request) -> Response {
//   todo
// }

pub fn new(
// TODO: add parameters
// create_fn: application.CreateReservation,
) -> ReservationHandler {
  todo
}
