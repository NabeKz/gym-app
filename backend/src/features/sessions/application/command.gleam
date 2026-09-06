import generated/requests.{type AuthInput}
import generated/responses.{type Member}
import gleam/result
import gleam/time/timestamp
import shared/password
import youid/uuid

pub type Authenticate =
  fn(AuthInput) -> Result(Member, String)

pub type FindMember =
  fn(uuid.Uuid) -> Result(Member, String)

pub type SaveSession =
  fn(uuid.Uuid, uuid.Uuid, String, timestamp.Timestamp) ->
    Result(String, String)

pub type DeleteSession =
  fn(String) -> Result(Nil, String)

pub type FindMemberIdByToken =
  fn(String) -> Result(uuid.Uuid, String)

pub type Login =
  fn(AuthInput) -> Result(#(Member, String), String)

pub type Logout =
  fn(String) -> Result(Nil, String)

pub type Me =
  fn(String) -> Result(Member, String)

pub fn login(authenticate: Authenticate, save_session: SaveSession) -> Login {
  fn(input) { do_login(authenticate, save_session, input) }
}

fn do_login(
  authenticate: Authenticate,
  save_session: SaveSession,
  input: AuthInput,
) -> Result(#(Member, String), String) {
  use member <- result.try(authenticate(input))
  let token = password.generate_salt()
  // generate_salt の乱数生成を token 生成にも流用
  let now = timestamp.system_time()
  use saved_token <- result.try(save_session(uuid.v4(), member.id, token, now))
  Ok(#(member, saved_token))
}

pub fn logout(delete_session: DeleteSession) -> Logout {
  delete_session
}

pub fn me(find_member_id: FindMemberIdByToken, find_member: FindMember) -> Me {
  fn(token) {
    use member_id <- result.try(find_member_id(token))
    find_member(member_id)
  }
}
