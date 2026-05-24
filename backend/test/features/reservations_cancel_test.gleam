// User Story: 会員として、不要になった予約をキャンセルしたい（requirements.md）

import features/reservations/application/command
import generated/responses.{type Lesson, Lesson}
import gleam/time/timestamp
import gleeunit/should
import youid/uuid

fn fixture_lesson(lesson_id: uuid.Uuid, starts_at: timestamp.Timestamp) -> Lesson {
  let assert Ok(ends_at) = timestamp.parse_rfc3339("2026-05-17T11:00:00Z")
  Lesson(
    id: lesson_id,
    name: "ヨガ",
    instructor: "田中",
    starts_at:,
    ends_at:,
    capacity: 10,
    remaining_slots: 5,
    description: "",
  )
}

pub fn cancel_success_test() {
  // 認証済み・自分の予約・レッスン開始前 → Ok(Nil)
  let reservation_id = uuid.v4()
  let member_id = uuid.v4()
  let lesson_id = uuid.v4()
  let assert Ok(now) = timestamp.parse_rfc3339("2026-05-17T09:00:00Z")
  let assert Ok(starts_at) = timestamp.parse_rfc3339("2026-05-17T10:00:00Z")

  let reservation = command.ReservationInfo(id: reservation_id, lesson_id:, member_id:)
  let read_reservation = fn(_: uuid.Uuid) { Ok(reservation) }
  let delete_reservation = fn(_: uuid.Uuid) { Ok(Nil) }
  let read_lesson = fn(_: uuid.Uuid) { Ok(fixture_lesson(lesson_id, starts_at)) }
  command.cancel(read_reservation, delete_reservation, read_lesson)(
    command.CancelInput(reservation_id:, member_id:, now:),
  )
  |> should.equal(Ok(Nil))
}

pub fn cancel_not_own_reservation_test() {
  // 他会員の予約 → Error
  let reservation_id = uuid.v4()
  let member_id = uuid.v4()
  let other_member_id = uuid.v4()
  let lesson_id = uuid.v4()
  let assert Ok(now) = timestamp.parse_rfc3339("2026-05-17T09:00:00Z")
  let assert Ok(starts_at) = timestamp.parse_rfc3339("2026-05-17T10:00:00Z")

  let reservation =
    command.ReservationInfo(id: reservation_id, lesson_id:, member_id: other_member_id)
  let read_reservation = fn(_: uuid.Uuid) { Ok(reservation) }
  let delete_reservation = fn(_: uuid.Uuid) { Ok(Nil) }
  let read_lesson = fn(_: uuid.Uuid) { Ok(fixture_lesson(lesson_id, starts_at)) }
  command.cancel(read_reservation, delete_reservation, read_lesson)(
    command.CancelInput(reservation_id:, member_id:, now:),
  )
  |> should.be_error
}

pub fn cancel_not_found_test() {
  // 存在しない予約 ID → Error
  let assert Ok(now) = timestamp.parse_rfc3339("2026-05-17T09:00:00Z")

  let read_reservation = fn(_: uuid.Uuid) { Error("not found") }
  let delete_reservation = fn(_: uuid.Uuid) { Ok(Nil) }
  let read_lesson = fn(_: uuid.Uuid) { Error("not found") }
  command.cancel(read_reservation, delete_reservation, read_lesson)(
    command.CancelInput(reservation_id: uuid.v4(), member_id: uuid.v4(), now:),
  )
  |> should.be_error
}

pub fn cancel_after_lesson_starts_test() {
  // レッスン開始済み → Error
  let reservation_id = uuid.v4()
  let member_id = uuid.v4()
  let lesson_id = uuid.v4()
  let assert Ok(now) = timestamp.parse_rfc3339("2026-05-17T11:00:00Z")
  let assert Ok(starts_at) = timestamp.parse_rfc3339("2026-05-17T10:00:00Z")

  let reservation = command.ReservationInfo(id: reservation_id, lesson_id:, member_id:)
  let read_reservation = fn(_: uuid.Uuid) { Ok(reservation) }
  let delete_reservation = fn(_: uuid.Uuid) { Ok(Nil) }
  let read_lesson = fn(_: uuid.Uuid) { Ok(fixture_lesson(lesson_id, starts_at)) }
  command.cancel(read_reservation, delete_reservation, read_lesson)(
    command.CancelInput(reservation_id:, member_id:, now:),
  )
  |> should.be_error
}
