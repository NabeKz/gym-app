import gleam/http
import gleam/list
import wisp.{type Request, type Response}

import app/handlers
import app/handlers/lessons
import app/middleware.{middleware}

pub fn handle_request(handlers: handlers.Handlers) {
  fn(req: Request) -> Response {
    use req <- middleware(req)

    case wisp.path_segments(req) {
      [] -> {
        wisp.log_debug("The home page:::")
        wisp.ok()
      }

      ["lessons", _] -> req |> lessons(handlers.lessons)

      _ -> {
        wisp.log_warning("User requested a route that does not exist")
        wisp.not_found()
      }
    }
  }
}

pub fn lessons(req: wisp.Request, h: lessons.LessonHandler) {
  let path = wisp.path_segments(req) |> list.drop(1)
  case path, req.method {
    [], http.Get -> req |> h.list()
    [], http.Post -> req |> h.create()
    [id], _ -> h.read(id)
    _, _ -> wisp.not_found()
  }
}
