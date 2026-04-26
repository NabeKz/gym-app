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
    type = timestamptz
    null = false
  }
  column "ends_at" {
    type = timestamptz
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
    null = true
  }

  primary_key {
    columns = [column.id]
  }
}
