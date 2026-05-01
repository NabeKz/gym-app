import features/lessons/application/command

pub type CreateLesson =
  command.Create

pub type CreateAdaptor =
  command.CreateAdaptor

pub fn create(adaptor: CreateAdaptor) -> CreateLesson {
  command.create(adaptor)
}
