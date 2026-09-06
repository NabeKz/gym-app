import domain/member.{type MemberRecord}
import generated/responses.{type Member, Member}
import gleam/result
import youid/uuid

pub type FindMemberById =
  fn(uuid.Uuid) -> Result(MemberRecord, String)

pub type FindMember =
  fn(uuid.Uuid) -> Result(Member, String)

fn to_member(record: MemberRecord) -> Member {
  Member(id: record.id, email: record.email)
}

fn do_find(adaptor: FindMemberById, id: uuid.Uuid) -> Result(Member, String) {
  adaptor(id)
  |> result.map(to_member)
}

pub fn find(adaptor: FindMemberById) -> FindMember {
  do_find(adaptor, _)
}
