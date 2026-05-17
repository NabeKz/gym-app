// User Story: スタッフとして、レッスンのスケジュールを登録したい（requirements.md）

import features/lessons/application/command
import generated/requests.{CreateLessonInput}
import generated/responses.{type Lesson}
import gleeunit/should

pub fn create_lesson_success_test() {
  let input = CreateLessonInput(
    name: "ヨガ",
    instructor: "田中",
    starts_at: "2026-05-16T10:00:00Z",
    ends_at: "2026-05-16T11:00:00Z",
    capacity: 10,
    description: "初心者向け",
  )
  let save = fn(lesson: Lesson) { Ok(lesson) }

  let assert Ok(lesson) = command.create(save)(input)

  lesson.name |> should.equal("ヨガ")
  lesson.instructor |> should.equal("田中")
  lesson.capacity |> should.equal(10)
  lesson.description |> should.equal("初心者向け")
}

pub fn create_lesson_remaining_slots_equals_capacity_test() {
  let input = CreateLessonInput(
    name: "ヨガ",
    instructor: "田中",
    starts_at: "2026-05-16T10:00:00Z",
    ends_at: "2026-05-16T11:00:00Z",
    capacity: 5,
    description: "",
  )
  let save = fn(lesson: Lesson) { Ok(lesson) }

  let assert Ok(lesson) = command.create(save)(input)

  lesson.remaining_slots |> should.equal(lesson.capacity)
}

pub fn create_lesson_adaptor_error_test() {
  let input = CreateLessonInput(
    name: "ヨガ",
    instructor: "田中",
    starts_at: "2026-05-16T10:00:00Z",
    ends_at: "2026-05-16T11:00:00Z",
    capacity: 10,
    description: "",
  )
  let save = fn(_: Lesson) { Error("db error") }

  command.create(save)(input) |> should.be_error
}
