import features/reservations/application/command

pub type CreateReservation =
  command.Create

pub type CreateAdaptor =
  command.CreateAdaptor

pub const create = command.create
