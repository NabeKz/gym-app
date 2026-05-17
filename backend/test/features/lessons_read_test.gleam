// User Story: 会員として、開催予定のレッスン一覧を空き状況付きで確認したい（requirements.md）

import features/lessons/application/query
import generated/responses.{type Lesson, Lesson}
import gleam/time/timestamp
import gleeunit/should
import youid/uuid

fn fixture_lesson() -> Lesson {
  let assert Ok(starts_at) = timestamp.parse_rfc3339("2026-05-16T10:00:00Z")
  let assert Ok(ends_at) = timestamp.parse_rfc3339("2026-05-16T11:00:00Z")
  Lesson(
    id: uuid.v4(),
    name: "ヨガ",
    instructor: "田中",
    starts_at:,
    ends_at:,
    capacity: 10,
    remaining_slots: 10,
    description: "",
  )
}

pub fn read_lesson_success_test() {
  let lesson = fixture_lesson()
  let adaptor = fn(_: uuid.Uuid) { Ok(lesson) }

  query.read(adaptor)(uuid.v4()) |> should.equal(Ok(lesson))
}

pub fn read_lesson_not_found_test() {
  let adaptor = fn(_: uuid.Uuid) { Error("not found") }

  query.read(adaptor)(uuid.v4()) |> should.be_error
}
