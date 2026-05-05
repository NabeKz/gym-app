import gleam/result
import gleam/string
import pog
import wisp
import features/reservations/application/command
import features/reservations/application/query
import features/reservations/sql
// TODO: implement adaptors
// Example:
pub fn create(db: pog.Connection) -> command.CreateAdaptor {
  fn(item) {
    db
    |> sql.create_reservation(/* fields */)
    |> result.map(fn(_) { item })
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to save reservation"
    })
  }
}
