import gleam/http
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

      ["lessons"] -> req |> lessons(handlers.lessons)

      _ -> {
        wisp.log_warning("User requested a route that does not exist")
        wisp.not_found()
      }
    }
  }
}

pub fn lessons(req: wisp.Request, h: lessons.LessonHandler) {
  let path = wisp.path_segments(req)
  case path, req.method {
    ["lessons"], http.Get -> req |> h.list()
    ["lessons"], http.Post -> req |> h.create()
    ["lessons", id], http.Get -> h.read(id)
    _, _ -> wisp.not_found()
  }
}
