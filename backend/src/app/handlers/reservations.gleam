import generated/requests
import generated/responses
import wisp.{type Request, type Response}

import app/handlers/request
import app/handlers/response
import features/reservations/application

pub type ReservationHandler {
  ReservationHandler(create: fn(Request) -> Response)
}

fn create(create_fn: application.CreateReservation, req: Request) -> Response {
  use input <- request.require_json_body(
    req,
    requests.parse_create_reservation_input,
  )
  case input |> create_fn() {
    Ok(reservation) ->
      reservation
      |> responses.encode_reservation
      |> response.json_response(201)

    Error(err) -> wisp.bad_request(err)
  }
}

pub fn new(create_fn: application.CreateReservation) -> ReservationHandler {
  ReservationHandler(create: create(create_fn, _))
}
