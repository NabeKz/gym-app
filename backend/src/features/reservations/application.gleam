import features/reservations/application/command

pub type CreateReservation =
  command.CreateReservation

pub type SaveReservation =
  command.SaveReservation

pub const create = command.create
