import generated/responses.{type Lesson}
import youid/uuid

pub type ListAdaptor =
  fn(Nil) -> Result(List(Lesson), String)

pub type ReadAdaptor =
  fn(uuid.Uuid) -> Result(Lesson, String)

pub type LessonList =
  fn(Nil) -> Result(List(Lesson), String)

pub type ReadLesson =
  fn(uuid.Uuid) -> Result(Lesson, String)

fn do_list(adaptor: ListAdaptor, input: Nil) -> Result(List(Lesson), String) {
  adaptor(input)
}

pub fn list(adaptor: ListAdaptor) {
  do_list(adaptor, _)
}

fn do_read(adaptor: ReadAdaptor, id: uuid.Uuid) {
  adaptor(id)
}

pub fn read(adaptor: ReadAdaptor) {
  do_read(adaptor, _)
}
