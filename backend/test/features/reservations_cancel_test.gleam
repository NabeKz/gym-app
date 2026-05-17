// User Story: 会員として、不要になった予約をキャンセルしたい（requirements.md）

import gleeunit/should

pub fn cancel_success_test() {
  todo
  // 認証済み・自分の予約・レッスン開始前 → 204
  // Reservation 削除・CancelledReservation 作成・remaining_slots +1
}

pub fn cancel_not_own_reservation_test() {
  todo
  // 他会員の予約 → 403
}

pub fn cancel_not_found_test() {
  todo
  // 存在しない予約 ID → 404
}

pub fn cancel_after_lesson_starts_test() {
  todo
  // レッスン開始済み → 409
}
