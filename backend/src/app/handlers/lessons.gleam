import features/lessons/application
import generated/requests
import pog
import wisp.{type Request, type Response}

pub type LessonHandler {
  LessonHandler(create: fn(Request) -> Response)
}

pub fn create(create_lesson: application.CreateLesson) {
  fn(req: Request) {
    use body <- wisp.require_string_body(req)
    case requests.decode_create_lesson_input(body) {
      Error(_) -> wisp.unprocessable_content()
      Ok(input) ->
        case create_lesson(input) {
          Ok(_) -> wisp.ok()
          Error(err) -> wisp.bad_request(err)
        }
    }
  }
}

pub fn new(_db: pog.Connection) {
  LessonHandler(
    create: application.create
    |> create(),
  )
}
