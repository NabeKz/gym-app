// import gleam/json
// import gleam/http/request
import generated/requests
import gleam/json
import wisp.{type Request, type Response}

// import app/handlers/error_responses
// import app/handlers/validation
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
fn create(create_fn: application.CreateReservation, req: Request) -> Response {
  use json <- wisp.require_json(req)

  case json |> requests.parse_create_reservation_input {
    Ok(input) -> todo
    Error(err) -> todo
  }
}

pub fn new(
  // TODO: add parameters
  create_fn: application.CreateReservation,
) -> ReservationHandler {
  ReservationHandler(create: create(create_fn, _))
}
