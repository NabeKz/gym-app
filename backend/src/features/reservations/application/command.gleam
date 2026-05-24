import gleam/order
import gleam/result
import gleam/time/timestamp
import youid/uuid

import generated/requests
import generated/responses.{type Lesson, type Reservation}

pub type SaveReservation =
  fn(ReservationInfo) -> Result(Reservation, String)

pub type DecrementRemainingSlots =
  fn(uuid.Uuid) -> Result(Nil, String)

pub type CreateReservation =
  fn(uuid.Uuid, requests.CreateReservationInput) -> Result(Reservation, String)

pub fn create(
  save: SaveReservation,
  decrement_slots: DecrementRemainingSlots,
) -> CreateReservation {
  fn(member_id, input) { do_create(save, decrement_slots, member_id, input) }
}

fn do_create(
  save: SaveReservation,
  decrement_slots: DecrementRemainingSlots,
  member_id: uuid.Uuid,
  input: requests.CreateReservationInput,
) -> Result(Reservation, String) {
  let info = ReservationInfo(id: uuid.v4(), lesson_id: input.lesson_id, member_id:)
  use reservation <- result.try(save(info))
  use _ <- result.try(decrement_slots(input.lesson_id))
  Ok(reservation)
}

pub type ReservationInfo {
  ReservationInfo(
    id: uuid.Uuid,
    lesson_id: uuid.Uuid,
    member_id: uuid.Uuid,
  )
}

pub type ReadReservationInfo =
  fn(uuid.Uuid) -> Result(ReservationInfo, String)

pub type DeleteReservation =
  fn(uuid.Uuid) -> Result(Nil, String)

pub type ReadLessonForCancel =
  fn(uuid.Uuid) -> Result(Lesson, String)

pub type IncrementRemainingSlots =
  fn(uuid.Uuid) -> Result(Nil, String)

pub type CancelInput {
  CancelInput(
    reservation_id: uuid.Uuid,
    member_id: uuid.Uuid,
    now: timestamp.Timestamp,
  )
}

pub type Cancel =
  fn(CancelInput) -> Result(Nil, String)

pub fn cancel(
  read_reservation: ReadReservationInfo,
  delete_reservation: DeleteReservation,
  read_lesson: ReadLessonForCancel,
  increment_slots: IncrementRemainingSlots,
) -> Cancel {
  do_cancel(read_reservation, delete_reservation, read_lesson, increment_slots, _)
}

fn check_ownership(reservation: ReservationInfo, member_id: uuid.Uuid) -> Result(Nil, String) {
  case reservation.member_id == member_id {
    True -> Ok(Nil)
    False -> Error("not your reservation")
  }
}

fn check_not_started(now: timestamp.Timestamp, lesson: Lesson) -> Result(Nil, String) {
  case timestamp.compare(now, lesson.starts_at) {
    order.Lt -> Ok(Nil)
    _ -> Error("lesson has already started")
  }
}

fn do_cancel(
  read_reservation: ReadReservationInfo,
  delete_reservation: DeleteReservation,
  read_lesson: ReadLessonForCancel,
  increment_slots: IncrementRemainingSlots,
  input: CancelInput,
) -> Result(Nil, String) {
  use reservation <- result.try(read_reservation(input.reservation_id))
  use _ <- result.try(check_ownership(reservation, input.member_id))
  use lesson <- result.try(read_lesson(reservation.lesson_id))
  use _ <- result.try(check_not_started(input.now, lesson))
  use _ <- result.try(delete_reservation(input.reservation_id))
  increment_slots(reservation.lesson_id)
}
