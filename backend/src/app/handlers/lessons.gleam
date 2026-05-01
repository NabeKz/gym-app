import generated/requests
import pog
import wisp.{type Request, type Response}

import app/handlers/error_responses
import features/lessons/adaptor/rbd
import features/lessons/application

pub type LessonHandler {
  LessonHandler(create: fn(Request) -> Response)
}

pub fn create(
  create_lesson: application.CreateLesson,
  req: Request,
) -> Response {
  use body <- wisp.require_string_body(req)

  use input <- error_responses.require_ok(
    body
    |> requests.parse_create_lesson_input(),
  )

  case create_lesson(input) {
    Ok(_) -> wisp.ok()
    Error(err) -> wisp.bad_request(err)
  }
}

pub fn new(db: pog.Connection) {
  let create_lesson = application.create(rbd.create(db))
  LessonHandler(create: create(create_lesson, _))
}
