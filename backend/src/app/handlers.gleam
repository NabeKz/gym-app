import app/handlers/lessons
import app/handlers/reservations

pub type Handlers {
  Handlers(
    lessons: lessons.LessonHandler,
    reservations: reservations.ReservationHandler,
  )
}
