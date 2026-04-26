import gleam/erlang/process
import gleam/otp/actor
import pog
import shared/env

pub fn start() -> pog.Connection {
  let database_url = case env.get("DATABASE_URL") {
    Ok(url) -> url
    Error(Nil) -> panic as "DATABASE_URL is not set"
  }

  let pool_name = process.new_name("db_pool")
  let assert Ok(config) = pog.url_config(pool_name, database_url)
  let assert Ok(actor.Started(_, conn)) = pog.start(config)
  conn
}
