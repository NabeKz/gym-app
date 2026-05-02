import generated/requests
import generated/responses
import gleam/json
import wisp.{type Request, type Response}

import app/handlers/error_responses
import features/lessons/application

pub type LessonHandler {
  LessonHandler(create: fn(Request) -> Response, list: fn(Request) -> Response)
}

fn create(create_lesson: application.CreateLesson, req: Request) -> Response {
  use body <- wisp.require_string_body(req)

  use input <- error_responses.require_ok(
    body
    |> requests.parse_create_lesson_input(),
  )

  case create_lesson(input) {
    Ok(lesson) ->
      lesson
      |> responses.encode_lesson
      |> json.to_string
      |> wisp.json_response(201)
    Error(err) -> wisp.bad_request(err)
  }
}

fn list(list_lesson: application.ListLesson, _req: Request) -> Response {
  case list_lesson() {
    Ok(rows) -> {
      rows
      |> json.array(responses.encode_lesson)
      |> json.to_string
      |> wisp.json_response(200)
    }
    Error(err) -> wisp.bad_request(err)
  }
}

pub fn new(
  create_lesson: application.CreateLesson,
  list_lesson: application.ListLesson,
) {
  LessonHandler(create: create(create_lesson, _), list: list(list_lesson, _))
}
