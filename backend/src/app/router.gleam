import app/handlers/reservations
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

      ["lessons", ..path] -> req |> lessons(path, handlers.lessons)
      ["reservations", ..path] -> req |> reservations(path, handlers.reservations)
      _ -> {
        wisp.log_warning("User requested a route that does not exist")
        wisp.not_found()
      }
    }
  }
}

pub fn lessons(
  req: wisp.Request,
  path: List(String),
  h: lessons.LessonHandler,
) {
  case path, req.method {
    [], http.Get -> req |> h.list()
    [], http.Post -> req |> h.create()
    [id], http.Get -> id |> h.read()
    _, _ -> wisp.not_found()
  }
}

pub fn reservations(
  req: wisp.Request,
  path: List(String),
  h: reservations.ReservationHandler,
) {
  case path, req.method {
    [], http.Get -> wisp.ok()
    [], http.Post -> req |> h.create()
    _, _ -> wisp.not_found()
  }
}
