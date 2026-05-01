import gleam/time/timestamp
import youid/uuid

import generated/requests
import generated/responses

pub type CreateAdaptor =
  fn(responses.Lesson) -> Result(responses.Lesson, String)

pub type Create =
  fn(requests.CreateLessonInput) -> Result(responses.Lesson, String)

fn do_create(
  adaptor: CreateAdaptor,
  input: requests.CreateLessonInput,
) -> Result(responses.Lesson, String) {
  let id = uuid.v4() |> uuid.to_string()
  let assert Ok(starts_at) = timestamp.parse_rfc3339(input.starts_at)
  let assert Ok(ends_at) = timestamp.parse_rfc3339(input.ends_at)
  responses.Lesson(
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

pub fn create(adaptor: CreateAdaptor) -> Create {
  fn(input) { do_create(adaptor, input) }
}
