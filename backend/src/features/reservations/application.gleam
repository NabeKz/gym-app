import features/reservations/application/command

pub type CreateReservation =
  command.CreateReservation

pub type SaveReservation =
  command.SaveReservation

pub type Cancel =
  command.Cancel

pub type ReadReservationInfo =
  command.ReadReservationInfo

pub type DeleteReservation =
  command.DeleteReservation

pub type ReadLessonForCancel =
  command.ReadLessonForCancel

pub const create = command.create

pub const cancel = command.cancel
