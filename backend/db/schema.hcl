schema "public" {}

schema "app" {}

table "lessons" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "name" {
    type = varchar(255)
    null = false
  }
  column "instructor" {
    type = varchar(255)
    null = false
  }
  column "starts_at" {
    type = timestamp
    null = false
  }
  column "ends_at" {
    type = timestamp
    null = false
  }
  column "capacity" {
    type = int
    null = false
  }
  column "remaining_slots" {
    type = int
    null = false
  }
  column "description" {
    type = text
    null = false
  }

  primary_key {
    columns = [column.id]
  }
}

table "reservations" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "lesson_id" {
    type = uuid
    null = false
  }
  column "member_id" {
    type = uuid
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  foreign_key "reservations_lesson_id_fkey" {
    columns     = [column.lesson_id]
    ref_columns = [table.lessons.column.id]
  }
}
