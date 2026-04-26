// This file is auto-generated from openapi.yaml. Do not edit manually.
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}

pub type CreateLessonInput {
  CreateLessonInput(
    name: String,
    instructor: String,
    starts_at: String,
    ends_at: String,
    capacity: Int,
    description: Option(String),
  )
}

pub fn decode_create_lesson_input(json_string: String) -> Result(CreateLessonInput, json.DecodeError) {
  json.parse(json_string, {
    use name <- decode.field("name", decode.string)
    use instructor <- decode.field("instructor", decode.string)
    use starts_at <- decode.field("startsAt", decode.string)
    use ends_at <- decode.field("endsAt", decode.string)
    use capacity <- decode.field("capacity", decode.int)
    use description <- decode.optional_field("description", option.None, decode.optional(decode.string))
    decode.success(CreateLessonInput(
      name:,
      instructor:,
      starts_at:,
      ends_at:,
      capacity:,
      description:,
    ))
  })
}
