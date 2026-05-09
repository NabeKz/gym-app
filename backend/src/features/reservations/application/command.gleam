import generated/requests
import generated/responses.{type Reservation}

pub type SaveReservation =
  fn(Reservation) -> Result(Reservation, String)

pub type CreateReservation =
  fn(requests.CreateReservationInput) -> Result(Reservation, String)

pub fn create(adaptor: SaveReservation) -> CreateReservation {
  do_create(adaptor, _)
}

fn do_create(
  adaptor: SaveReservation,
  input: requests.CreateReservationInput,
) -> Result(Reservation, String) {
  responses.Reservation(id: input.lesson_id, name: "sample")
  |> adaptor()
}
