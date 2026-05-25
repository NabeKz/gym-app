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
  column "description" {
    type = text
    null = false
  }

  primary_key {
    columns = [column.id]
  }
}

table "members" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "email" {
    type = varchar(255)
    null = false
  }
  column "password_hash" {
    type = text
    null = false
  }
  column "salt" {
    type = text
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  unique "members_email_key" {
    columns = [column.email]
  }
}

table "sessions" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "member_id" {
    type = uuid
    null = false
  }
  column "token" {
    type = text
    null = false
  }
  column "created_at" {
    type = timestamp
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  unique "sessions_token_key" {
    columns = [column.token]
  }

  foreign_key "sessions_member_id_fkey" {
    columns     = [column.member_id]
    ref_columns = [table.members.column.id]
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

  foreign_key "reservations_member_id_fkey" {
    columns     = [column.member_id]
    ref_columns = [table.members.column.id]
  }

  unique "reservations_lesson_member_key" {
    columns = [column.lesson_id, column.member_id]
  }
}
