import { vstack, hstack } from "styled-system/patterns"
import { css, cva } from "styled-system/css"
import { getLessons } from "@/shared/generated/openapi.gen"
import { use } from "react"
import type { Lesson } from "@/shared/generated/openapi.gen"
import { parseDate, formatDateTime, formatTime } from "@/shared/lib/date"
import { ReserveButton } from "./reserve-button"
import { emptyText } from "@/shared/ui/styles"

const LessonCard = ({ lesson, onReserved }: { lesson: Lesson; onReserved: () => void }) => {
  const startsAt = parseDate(lesson.startsAt)
  const endsAt = parseDate(lesson.endsAt)

  const isFull = lesson.remainingSlots === 0
  const isAlmostFull = !isFull && lesson.remainingSlots <= 3
  const slotsStatus = isFull ? "full" : isAlmostFull ? "almostFull" : "available"

  return (
    <div className={card}>
      <div className={hstack({ justify: "space-between" })}>
        <div className={vstack({ gap: "xs", alignItems: "flex-start" })}>
          <h2 className={lessonName}>{lesson.name}</h2>
          <span className={instructorLabel}>講師: {lesson.instructor}</span>
        </div>
        <span className={slotsBadge({ status: slotsStatus })}>
          残席 {lesson.remainingSlots} / {lesson.capacity}
        </span>
      </div>

      <div className={timeRow}>
        {formatDateTime(startsAt)} 〜 {formatTime(endsAt)}
      </div>

      {lesson.description && <p className={descText}>{lesson.description}</p>}

      <div className={hstack({ justify: "flex-end" })}>
        <ReserveButton lesson={lesson} onReserved={onReserved} />
      </div>
    </div>
  )
}

export const LessonList = ({
  promise,
  onReserved,
}: {
  promise: ReturnType<typeof getLessons>
  onReserved: () => void
}) => {
  const { data: items } = use(promise)

  if (items.length === 0) {
    return <p className={emptyText}>現在予約できるレッスンはありません</p>
  }

  return (
    <div className={vstack({ gap: "md", alignItems: "stretch", w: "full" })}>
      {items.map((item) => (
        <LessonCard key={item.id} lesson={item} onReserved={onReserved} />
      ))}
    </div>
  )
}

const card = css({
  borderWidth: "1px",
  borderStyle: "solid",
  borderColor: "gray.200",
  borderRadius: "lg",
  p: "lg",
  bg: "white",
  boxShadow: "sm",
  display: "flex",
  flexDirection: "column",
  gap: "sm",
})

const lessonName = css({ fontSize: "lg", fontWeight: "semibold" })
const instructorLabel = css({ fontSize: "sm", color: "gray.500" })
const timeRow = css({ fontSize: "sm", color: "gray.600" })
const descText = css({ fontSize: "sm", color: "gray.700", whiteSpace: "pre-wrap" })

const slotsBadge = cva({
  base: {
    fontSize: "xs",
    fontWeight: "medium",
    px: "sm",
    py: "xs",
    borderRadius: "full",
  },
  variants: {
    status: {
      full: { bg: "red.100", color: "red.700" },
      almostFull: { bg: "orange.100", color: "orange.700" },
      available: { bg: "green.100", color: "green.700" },
    },
  },
})
