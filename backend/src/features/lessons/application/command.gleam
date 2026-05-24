import gleam/time/timestamp
import youid/uuid

import generated/requests
import generated/responses.{type Lesson, Lesson}

pub type SaveLesson =
  fn(Lesson) -> Result(Lesson, String)

pub type DecrementRemainingSlots =
  fn(uuid.Uuid) -> Result(Nil, String)

pub type CreateLesson =
  fn(requests.CreateLessonInput) -> Result(Lesson, String)

fn do_create(
  adaptor: SaveLesson,
  input: requests.CreateLessonInput,
) -> Result(Lesson, String) {
  let id = uuid.v4()
  let assert Ok(starts_at) = timestamp.parse_rfc3339(input.starts_at)
  let assert Ok(ends_at) = timestamp.parse_rfc3339(input.ends_at)
  Lesson(
    id:,
    name: input.name,
    instructor: input.instructor,
    starts_at:,
    ends_at:,
    capacity: input.capacity,
    remaining_slots: input.capacity,
    description: input.description,
  )
  |> adaptor()
}

pub fn create(adaptor: SaveLesson) -> CreateLesson {
  do_create(adaptor, _)
}
