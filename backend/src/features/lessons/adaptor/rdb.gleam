import pog

import features/lessons/application/command
import generated/responses

fn do_create(
  db: pog.Connection,
  lesson: responses.Lesson,
) -> Result(responses.Lesson, String) {
  let result =
    pog.query(
      "INSERT INTO lessons
         (id, name, instructor, starts_at, ends_at, capacity, remaining_slots, description)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
    )
    |> pog.parameter(pog.text(lesson.id))
    |> pog.parameter(pog.text(lesson.name))
    |> pog.parameter(pog.text(lesson.instructor))
    |> pog.parameter(pog.timestamp(lesson.starts_at))
    |> pog.parameter(pog.timestamp(lesson.ends_at))
    |> pog.parameter(pog.int(lesson.capacity))
    |> pog.parameter(pog.int(lesson.remaining_slots))
    |> pog.parameter(pog.nullable(pog.text, lesson.description))
    |> pog.execute(db)

  case result {
    Ok(_) -> Ok(lesson)
    Error(_) -> Error("Failed to save lesson")
  }
}

pub fn create(db: pog.Connection) -> command.CreateAdaptor {
  do_create(db, _)
}
