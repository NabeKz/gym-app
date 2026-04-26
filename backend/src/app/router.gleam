import app/handlers/lessons
import gleam/http
import wisp.{type Connection, type Request, type Response}

import app/handlers
import app/middleware.{middleware}

pub fn handle_request(handlers: handlers.Handlers) {
  fn(req: Request) -> Response {
    use req <- middleware(req)

    case wisp.path_segments(req) {
      [] -> {
        wisp.log_debug("The home page:::")
        wisp.ok()
      }

      ["lessons"] -> req |> lessons(handlers.lessons)

      _ -> {
        wisp.log_warning("User requested a route that does not exist")
        wisp.not_found()
      }
    }
  }
}

pub fn lessons(req: wisp.Request, h: lessons.LessonHandler) {
  case req.method {
    http.Post -> req |> h.create()
    _ -> wisp.not_found()
  }
}
