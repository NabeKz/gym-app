import app/handlers/lessons
import pog

pub type Handlers {
  Handlers(lessons: lessons.LessonHandler)
}

pub fn new(db: pog.Connection) {
  let lessons = lessons.new(db)
  Handlers(lessons:)
}
