import gleam/result
import pog
import youid/uuid

import features/lessons/application/command
import features/lessons/sql
import generated/responses

fn do_create(
  db: pog.Connection,
  lesson: responses.Lesson,
) -> Result(responses.Lesson, String) {
  let assert Ok(id) = uuid.from_string(lesson.id)
  sql.create_lesson(
    db,
    id,
    lesson.name,
    lesson.instructor,
    lesson.starts_at,
    lesson.ends_at,
    lesson.capacity,
    lesson.remaining_slots,
    lesson.description,
  )
  |> result.map(fn(_) { lesson })
  |> result.map_error(fn(_) { "Failed to save lesson" })
}

pub fn create(db: pog.Connection) -> command.CreateAdaptor {
  do_create(db, _)
}
