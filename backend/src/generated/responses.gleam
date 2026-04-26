// This file is auto-generated from openapi.yaml. Do not edit manually.
import gleam/json
import gleam/option.{type Option}

pub type Exercise {
  Exercise(
    id: Int,
    name: String,
    muscle_group: Option(String),
  )
}

pub fn encode_exercise(value: Exercise) -> json.Json {
  json.object([
    #("id", json.int(value.id)),
    #("name", json.string(value.name)),
    #("muscleGroup", json.nullable(value.muscle_group, json.string)),
  ])
}

pub type WorkoutSet {
  WorkoutSet(
    id: Int,
    reps: Int,
    weight_kg: Option(Float),
  )
}

pub fn encode_workout_set(value: WorkoutSet) -> json.Json {
  json.object([
    #("id", json.int(value.id)),
    #("reps", json.int(value.reps)),
    #("weightKg", json.nullable(value.weight_kg, json.float)),
  ])
}

pub type WorkoutExercise {
  WorkoutExercise(
    id: Int,
    exercise: Exercise,
    sets: List(WorkoutSet),
  )
}

pub fn encode_workout_exercise(value: WorkoutExercise) -> json.Json {
  json.object([
    #("id", json.int(value.id)),
    #("exercise", encode_exercise(value.exercise)),
    #("sets", json.array(value.sets, fn(item) { encode_workout_set(item) })),
  ])
}

pub type Workout {
  Workout(
    id: Int,
    date: String,
    notes: Option(String),
    exercises: List(WorkoutExercise),
  )
}

pub fn encode_workout(value: Workout) -> json.Json {
  json.object([
    #("id", json.int(value.id)),
    #("date", json.string(value.date)),
    #("notes", json.nullable(value.notes, json.string)),
    #("exercises", json.array(value.exercises, fn(item) { encode_workout_exercise(item) })),
  ])
}
