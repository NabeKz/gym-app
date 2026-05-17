import gleam/http/request
import gleam/http/response
import gleam/json
import wisp.{type Request, type Response}
import youid/uuid

import app/handlers/request as req_helper
import features/reservations/application
import features/reservations/application/command
import generated/requests
import generated/responses
import shared/date

pub type ReservationHandler {
  ReservationHandler(
    create: fn(Request) -> Response,
    cancel: fn(Request, String) -> Response,
  )
}

fn create(create_fn: application.CreateReservation, req: Request) -> Response {
  use member_id <- require_member_id(req)
  use input <- req_helper.require_json_body(req, requests.parse_create_reservation_input)
  case create_fn(member_id, input) {
    Ok(reservation) ->
      reservation
      |> responses.encode_reservation
      |> json.to_string
      |> wisp.json_response(201)
    Error(err) -> wisp.bad_request(err)
  }
}

fn cancel(cancel_fn: application.Cancel, req: Request, id: String) -> Response {
  use member_id <- require_member_id(req)
  use reservation_id <- require_uuid(id)
  case cancel_fn(command.CancelInput(reservation_id:, member_id:, now: date.now())) {
    Ok(_) -> wisp.response(204)
    Error("not found") -> wisp.not_found()
    Error("not your reservation") -> wisp.response(403)
    Error("lesson has already started") -> wisp.response(409)
    Error(err) -> wisp.bad_request(err)
  }
}

fn require_member_id(req: Request, next: fn(uuid.Uuid) -> Response) -> Response {
  case request.get_header(req, "x-member-id") {
    Error(_) -> unauthorized()
    Ok(raw) ->
      case uuid.from_string(raw) {
        Error(_) -> unauthorized()
        Ok(id) -> next(id)
      }
  }
}

fn require_uuid(raw: String, next: fn(uuid.Uuid) -> Response) -> Response {
  case uuid.from_string(raw) {
    Error(_) -> wisp.not_found()
    Ok(id) -> next(id)
  }
}

fn unauthorized() -> Response {
  json.object([
    #("type", json.string("about:blank")),
    #("title", json.string("Unauthorized")),
    #("status", json.int(401)),
  ])
  |> json.to_string
  |> wisp.json_response(401)
  |> response.set_header("content-type", "application/problem+json")
}

pub fn new(
  create_fn: application.CreateReservation,
  cancel_fn: application.Cancel,
) -> ReservationHandler {
  ReservationHandler(
    create: create(create_fn, _),
    cancel: fn(req, id) { cancel(cancel_fn, req, id) },
  )
}
