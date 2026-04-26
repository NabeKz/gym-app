import generated/requests
import generated/responses
import shared/date
import youid/uuid

pub type Create =
  fn(requests.CreateLessonInput) -> Result(responses.Lesson, String)

fn do_create(input: requests.CreateLessonInput) -> Result(responses.Lesson, String) {
  echo input
  let id = uuid.v4() |> uuid.to_string()
  responses.Lesson(
    id:,
    name: input.name,
    instructor: input.instructor,
    starts_at: date.now(),
    ends_at: date.now(),
    capacity: input.capacity,
    remaining_slots: input.capacity,
    description: input.description,
  )
  |> Ok()
}

pub const create: Create = do_create
