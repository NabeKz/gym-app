import generated/requests
import generated/responses
import gleam/json
import wisp.{type Request, type Response}

import app/handlers/error_responses
import features/reservations/application

pub type ReservationHandler {
  ReservationHandler(create: fn(Request) -> Response)
}

fn create(create_fn: application.CreateReservation, req: Request) -> Response {
  use json <- wisp.require_json(req)

  use input <- error_responses.require_ok(
    json |> requests.parse_create_reservation_input,
  )
  case input |> create_fn() {
    Ok(reservation) -> {
      reservation
      |> responses.encode_reservation()
      |> json.to_string()
      |> wisp.json_response(201)
    }

    Error(err) -> {
      wisp.bad_request(err)
    }
  }
}

pub fn new(create_fn: application.CreateReservation) -> ReservationHandler {
  ReservationHandler(create: create(create_fn, _))
}
