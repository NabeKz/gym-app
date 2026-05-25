import gleam/erlang/process
import gleam/list
import gleam/otp/actor
import gleam/result
import gleam/string
import gleam/time/duration
import gleam/time/timestamp
import pog
import wisp
import youid/uuid.{type Uuid}

import features/lessons/sql as lessons_sql
import features/reservations/sql as reservations_sql
import generated/requests
import generated/responses.{type Reservation, Reservation}
import workflows/create_reservation

pub type ActorState {
  ActorState(conn: pog.Connection)
}

pub type Message {
  Reserve(
    reply_to: process.Subject(Result(Reservation, String)),
    member_id: Uuid,
    lesson_id: Uuid,
  )
  Shutdown
}

pub fn start(
  _lesson_id: Uuid,
  starts_at: timestamp.Timestamp,
  conn: pog.Connection,
) -> actor.StartResult(process.Subject(Message)) {
  let deadline = timestamp.subtract(starts_at, duration.minutes(15))
  let now = timestamp.system_time()
  let delay_ms =
    timestamp.difference(now, deadline)
    |> duration.to_milliseconds()

  case delay_ms <= 0 {
    True -> Error(actor.InitFailed("past deadline"))
    False -> {
      use started <- result.try(
        actor.new(ActorState(conn:))
        |> actor.on_message(handle_message)
        |> actor.start(),
      )
      process.send_after(started.data, delay_ms, Shutdown)
      Ok(started)
    }
  }
}

fn handle_message(
  state: ActorState,
  msg: Message,
) -> actor.Next(ActorState, Message) {
  case msg {
    Shutdown -> actor.stop()
    Reserve(reply_to:, member_id:, lesson_id:) -> {
      let result = do_reserve(state.conn, member_id, lesson_id)
      process.send(reply_to, result)
      actor.continue(state)
    }
  }
}

fn do_reserve(
  conn: pog.Connection,
  member_id: Uuid,
  lesson_id: Uuid,
) -> Result(Reservation, String) {
  let get_lesson = do_get_lesson(conn, _)
  let has_reservation = fn(lesson_id, mid) {
    do_has_reservation(conn, lesson_id, mid)
  }
  let save = do_save(conn, _)
  create_reservation.create(get_lesson, has_reservation, save)(
    member_id,
    requests.CreateReservationInput(lesson_id:),
  )
}

fn do_get_lesson(
  conn: pog.Connection,
  id: Uuid,
) -> Result(create_reservation.LessonInfo, String) {
  use returned <- result.try(
    conn
    |> lessons_sql.read_lesson_capacity(id)
    |> result.map_error(fn(e) {
      wisp.log_error(string.inspect(e))
      "Failed to read lesson"
    }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  Ok(create_reservation.LessonInfo(
    capacity: row.capacity,
    reserved_count: row.reserved_count,
  ))
}

fn do_has_reservation(
  conn: pog.Connection,
  lesson_id: Uuid,
  member_id: Uuid,
) -> Result(Bool, String) {
  conn
  |> reservations_sql.read_member_reservation(lesson_id, member_id)
  |> result.map(fn(returned) { !list.is_empty(returned.rows) })
  |> result.map_error(fn(e) {
    wisp.log_error(string.inspect(e))
    "Failed to check reservation"
  })
}

fn do_save(
  conn: pog.Connection,
  info: create_reservation.ReservationInfo,
) -> Result(Reservation, String) {
  conn
  |> reservations_sql.create_reservation(info.id, info.lesson_id, info.member_id)
  |> result.map(fn(_) { Reservation(id: info.id, name: "") })
  |> result.map_error(fn(e) {
    wisp.log_error(string.inspect(e))
    "Failed to create reservation"
  })
}
