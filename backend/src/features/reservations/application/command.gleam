import generated/requests
import generated/responses.{type Reservation, Reservation}
import youid/uuid

pub type SaveReservation =
  fn(Reservation) -> Result(Reservation, String)

pub type CreateReservation =
  fn(requests.CreateReservationInput) -> Result(Reservation, String)

pub fn create(adaptor: SaveReservation) -> CreateReservation {
  do_create(adaptor, _)
}

fn do_create(
  adaptor: SaveReservation,
  _input: requests.CreateReservationInput,
) -> Result(Reservation, String) {
  uuid.v4()
  |> Reservation(name: "")
  |> adaptor()
}
