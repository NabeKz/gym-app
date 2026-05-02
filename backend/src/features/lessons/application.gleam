import features/lessons/application/command
import features/lessons/application/query

pub type CreateLesson =
  command.Create

pub type ListLesson =
  query.LessonList

pub type CreateAdaptor =
  command.CreateAdaptor

pub type ListAdaptor =
  query.ListAdaptor

pub fn create(adaptor: CreateAdaptor) -> CreateLesson {
  command.create(adaptor)
}

pub fn list(adaptor: ListAdaptor) -> ListLesson {
  fn() { query.list(adaptor) }
}
