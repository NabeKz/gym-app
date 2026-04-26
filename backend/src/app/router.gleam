import wisp.{type Request, type Response}

import app/middleware.{middleware}

pub fn handle_request(req: Request) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    [] -> {
      wisp.log_debug("The home page:::")
      wisp.ok()
    }

    ["about"] -> {
      wisp.log_info("They're reading about us")
      wisp.ok()
    }

    ["secret"] -> {
      wisp.log_error("The secret page was found!")
      wisp.ok()
    }

    _ -> {
      wisp.log_warning("User requested a route that does not exist")
      wisp.not_found()
    }
  }
}
