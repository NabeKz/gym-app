// This file is auto-generated from openapi.yaml. Do not edit manually.
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/option.{type Option}
import gleam/string
import gleam/time/timestamp

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

fn decode_create_lesson_input(json_string: String) -> Result(CreateLessonInput, json.DecodeError) {
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

fn validate_create_lesson_input(input: CreateLessonInput) -> Result(CreateLessonInput, List(String)) {
  let errors =
    []
    |> check_min_length("name", input.name, 1)
    |> check_min_length("instructor", input.instructor, 1)
    |> check_date_time("startsAt", input.starts_at)
    |> check_date_time("endsAt", input.ends_at)
    |> check_min_int("capacity", input.capacity, 1)
  case errors {
    [] -> Ok(input)
    _ -> Error(errors)
  }
}

pub fn parse_create_lesson_input(json_string: String) -> Result(CreateLessonInput, List(String)) {
  case decode_create_lesson_input(json_string) {
    Error(_) -> Error(["invalid request body"])
    Ok(input) -> validate_create_lesson_input(input)
  }
}

fn check_min_length(errors: List(String), field: String, value: String, min: Int) -> List(String) {
  case string.length(value) >= min {
    True -> errors
    False -> [field <> " must be at least " <> int.to_string(min) <> " characters", ..errors]
  }
}

fn check_date_time(errors: List(String), field: String, value: String) -> List(String) {
  case timestamp.parse_rfc3339(value) {
    Ok(_) -> errors
    Error(_) -> [field <> " is not a valid date-time", ..errors]
  }
}

fn check_min_int(errors: List(String), field: String, value: Int, min: Int) -> List(String) {
  case value >= min {
    True -> errors
    False -> [field <> " must be at least " <> int.to_string(min), ..errors]
  }
}
