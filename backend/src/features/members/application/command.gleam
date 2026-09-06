import domain/member.{type MemberRecord, MemberRecord}
import generated/requests.{type AuthInput}
import generated/responses.{type Member, Member}
import gleam/result
import shared/password
import youid/uuid

pub type SaveMember =
  fn(MemberRecord) -> Result(MemberRecord, String)

pub type FindMemberByEmail =
  fn(String) -> Result(MemberRecord, String)

pub type SignUp =
  fn(AuthInput) -> Result(Member, String)

/// メールアドレスとパスワードで本人を確認する。
/// パスワードハッシュとソルトを触るのはここまでで、MemberRecord を返す形に
/// 変えると認証情報が members の外へ出る。
pub type Authenticate =
  fn(AuthInput) -> Result(Member, String)

pub fn signup(
  save: SaveMember,
  find: FindMemberByEmail,
  pepper: String,
) -> SignUp {
  fn(input) { do_signup(save, find, pepper, input) }
}

fn do_signup(
  save: SaveMember,
  find: FindMemberByEmail,
  pepper: String,
  input: AuthInput,
) -> Result(Member, String) {
  case find(input.email) {
    Ok(_) -> Error("email already registered")
    Error(_) -> {
      let salt = password.generate_salt()
      let hash = password.hash(input.password, salt, pepper)
      let record =
        MemberRecord(
          id: uuid.v4(),
          email: input.email,
          password_hash: hash,
          salt:,
        )
      use saved <- result.try(save(record))
      Ok(Member(id: saved.id, email: saved.email))
    }
  }
}

pub fn authenticate(find: FindMemberByEmail, pepper: String) -> Authenticate {
  fn(input) { do_authenticate(find, pepper, input) }
}

fn do_authenticate(
  find: FindMemberByEmail,
  pepper: String,
  input: AuthInput,
) -> Result(Member, String) {
  use record <- result.try(
    find(input.email)
    |> result.map_error(fn(_) { "invalid email or password" }),
  )
  case
    password.verify(input.password, record.salt, pepper, record.password_hash)
  {
    False -> Error("invalid email or password")
    True -> Ok(Member(id: record.id, email: record.email))
  }
}
