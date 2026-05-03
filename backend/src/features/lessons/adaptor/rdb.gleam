import features/lessons/application
import gleam/list
import gleam/result
import gleam/string
import pog
import wisp
import youid/uuid

import features/lessons/application/command
import features/lessons/application/query
import features/lessons/sql
import generated/responses.{type Lesson, Lesson}

fn do_create(db: pog.Connection, lesson: Lesson) -> Result(Lesson, String) {
  db
  |> sql.create_lesson(
    lesson.id,
    lesson.name,
    lesson.instructor,
    lesson.starts_at,
    lesson.ends_at,
    lesson.capacity,
    lesson.remaining_slots,
    lesson.description,
  )
  |> result.map(fn(_) { lesson })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save lesson"
  })
}

pub fn create(db: pog.Connection) -> command.CreateAdaptor {
  do_create(db, _)
}

fn do_read(db: pog.Connection, id: uuid.Uuid) {
  use returned <- result.try(
    db
    |> sql.read_lesson(id)
    |> result.map_error(fn(_) { "Failed to read lesson" }),
  )

  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not unique" }),
  )

  Lesson(
    id: row.id,
    name: row.name,
    instructor: row.instructor,
    starts_at: row.starts_at,
    ends_at: row.ends_at,
    capacity: row.capacity,
    remaining_slots: row.remaining_slots,
    description: row.description,
  )
  |> Ok()
}

pub fn read(db: pog.Connection) -> application.ReadLesson {
  do_read(db, _)
}

fn do_list(db: pog.Connection, _input: Nil) -> Result(List(Lesson), String) {
  db
  |> sql.list_lesson()
  |> result.map(fn(r) {
    list.map(r.rows, fn(row) {
      Lesson(
        id: row.id,
        name: row.name,
        instructor: row.instructor,
        starts_at: row.starts_at,
        ends_at: row.ends_at,
        capacity: row.capacity,
        remaining_slots: row.remaining_slots,
        description: row.description,
      )
    })
  })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to list lesson"
  })
}

pub fn list(db: pog.Connection) -> query.ListAdaptor {
  do_list(db, _)
}
