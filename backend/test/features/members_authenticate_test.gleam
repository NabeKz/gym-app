// User Story: 会員として、メールアドレスとパスワードでログインしたい（docs/auth_workflow.md）

import domain/member.{type MemberRecord, MemberRecord}
import features/members/application/command
import generated/requests.{AuthInput}
import generated/responses.{Member}
import gleeunit/should
import shared/password
import youid/uuid

const pepper = "test-pepper"

const salt = "c2FsdA=="

fn m1() -> uuid.Uuid {
  let assert Ok(id) = uuid.from_string("01970000-0000-7000-8000-000000000001")
  id
}

fn fixture_record() -> MemberRecord {
  MemberRecord(
    id: m1(),
    email: "member@example.com",
    password_hash: password.hash("correct-password", salt, pepper),
    salt:,
  )
}

// test: 登録済みのメールアドレスと正しいパスワードなら会員が返る
pub fn authenticate_success_test() {
  let find = fn(_: String) { Ok(fixture_record()) }
  let input =
    AuthInput(email: "member@example.com", password: "correct-password")

  command.authenticate(find, pepper)(input)
  |> should.equal(Ok(Member(id: m1(), email: "member@example.com")))
}

// test: パスワードが違うと資格情報エラーになる
pub fn authenticate_wrong_password_test() {
  let find = fn(_: String) { Ok(fixture_record()) }
  let input = AuthInput(email: "member@example.com", password: "wrong-password")

  command.authenticate(find, pepper)(input)
  |> should.equal(Error("invalid email or password"))
}

// test: 登録されていないメールアドレスは資格情報エラーになる
pub fn authenticate_unknown_email_test() {
  let find = fn(_: String) { Error("not found") }
  let input =
    AuthInput(email: "stranger@example.com", password: "correct-password")

  command.authenticate(find, pepper)(input)
  |> should.equal(Error("invalid email or password"))
}

// test: pepper が違うと資格情報エラーになる
pub fn authenticate_wrong_pepper_test() {
  let find = fn(_: String) { Ok(fixture_record()) }
  let input =
    AuthInput(email: "member@example.com", password: "correct-password")

  command.authenticate(find, "other-pepper")(input)
  |> should.equal(Error("invalid email or password"))
}
