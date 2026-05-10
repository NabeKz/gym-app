import { hstack } from "styled-system/patterns"
import { css, cva } from "styled-system/css"
import { createReservation } from "@/shared/generated/openapi.gen"
import { useState, useTransition } from "react"
import type { Lesson } from "@/shared/generated/openapi.gen"

type ReserveState = "idle" | "pending" | "success" | "error"

export const ReserveButton = ({ lesson }: { lesson: Lesson }) => {
  const [isPending, startTransition] = useTransition()
  const [state, setState] = useState<ReserveState>("idle")

  const isFull = lesson.remainingSlots === 0

  const handleReserve = () => {
    startTransition(async () => {
      setState("pending")
      try {
        await createReservation({ lesson_id: lesson.id })
        setState("success")
      } catch {
        setState("error")
      }
    })
  }

  if (state === "success") {
    return <span className={successBadge}>予約完了</span>
  }

  return (
    <div className={hstack({ gap: "sm" })}>
      {state === "error" && <span className={errorText}>予約に失敗しました</span>}
      <button
        onClick={handleReserve}
        disabled={isPending || isFull}
        className={reserveBtn({ full: isFull })}
      >
        {isPending ? "予約中…" : isFull ? "満席" : "予約する"}
      </button>
    </div>
  )
}

const reserveBtn = cva({
  base: {
    px: "md",
    py: "sm",
    borderRadius: "md",
    fontSize: "sm",
    fontWeight: "medium",
    cursor: "pointer",
  },
  variants: {
    full: {
      true: { bg: "gray.100", color: "gray.400", cursor: "not-allowed" },
      false: {
        bg: "blue.600",
        color: "white",
        _hover: { bg: "blue.700" },
        _disabled: { opacity: "0.5", cursor: "not-allowed" },
      },
    },
  },
  defaultVariants: { full: false },
})

const successBadge = css({
  px: "sm",
  py: "xs",
  borderRadius: "full",
  fontSize: "sm",
  fontWeight: "medium",
  bg: "green.100",
  color: "green.700",
})

const errorText = css({ fontSize: "xs", color: "red.600" })
