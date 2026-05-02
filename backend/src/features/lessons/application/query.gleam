import generated/responses.{type Lesson}

pub type ListAdaptor =
  fn(Nil) -> Result(List(Lesson), String)

pub type LessonList =
  fn() -> Result(List(Lesson), String)

fn do_list(adaptor: ListAdaptor, input: Nil) -> Result(List(Lesson), String) {
  adaptor(input)
}

pub fn list(adaptor: ListAdaptor) {
  do_list(adaptor, Nil)
}
