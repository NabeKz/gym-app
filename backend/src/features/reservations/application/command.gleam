import generated/requests
import generated/responses.{type Reservation}

pub type CreateAdaptor =
  fn(Reservation) -> Result(Reservation, String)

pub type Create =
  fn(requests.CreateReservationInput) -> Result(Reservation, String)

pub fn create(adaptor: CreateAdaptor) -> Create {
  do_create(adaptor, _)
}

fn do_create(
  _adaptor: CreateAdaptor,
  input: requests.CreateReservationInput,
) -> Result(Reservation, String) {
  responses.Reservation(id: input.lesson_id, name: "sample")
  |> Ok()
}
