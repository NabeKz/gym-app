// User Story: 会員として、レッスンを予約したい（requirements.md）

import features/reservations/application/command
import generated/requests.{CreateReservationInput}
import generated/responses.{type Reservation}
import gleeunit/should
import youid/uuid

pub fn create_reservation_success_test() {
  let lesson_id = uuid.v4()
  let input = CreateReservationInput(lesson_id:)
  let save = fn(r: Reservation) { Ok(r) }

  let assert Ok(reservation) = command.create(save)(input)

  // id は lesson_id とは別の新しい UUID であること
  reservation.id |> should.not_equal(lesson_id)
}

pub fn create_reservation_adaptor_error_test() {
  let input = CreateReservationInput(lesson_id: uuid.v4())
  let save = fn(_: Reservation) { Error("db error") }

  command.create(save)(input) |> should.be_error
}
