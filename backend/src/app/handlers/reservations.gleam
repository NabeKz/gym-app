import gleam/json
import wisp.{type Request, type Response}

import app/handlers/error_responses
import app/handlers/validation
import features/reservations/application

pub type ReservationHandler {
  ReservationHandler(
    create: fn(Request) -> Response,
    // TODO: add handler fields
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
  create: application.CreateReservation,
) -> ReservationHandler {
  ReservationHandler(create)
}
