import features/lessons/application/command
import features/lessons/application/query

pub type CreateLesson =
  command.Create

pub type ReadLesson =
  query.ReadLesson

pub type ListLesson =
  query.LessonList

pub type CreateAdaptor =
  command.CreateAdaptor

pub type ListAdaptor =
  query.ListAdaptor

pub type ReadAdaptor =
  query.ReadAdaptor

pub const create = command.create

pub const read = query.read

pub const list = query.list
