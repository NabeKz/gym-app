import { grid, vstack } from "styled-system/patterns"
import { css } from "styled-system/css"
import { createLesson, getLessons } from "@/shared/generated/openapi.gen"
import { use, useState, Suspense, type ChangeEvent } from "react"

const LessonList = ({ promise }: { promise: ReturnType<typeof getLessons> }) => {
  const { data: items } = use(promise)

  return (
    <div className={vstack({})}>
      {items.map((item) => (
        <div key={item.id}>
          <div>レッスン名: {item.name}</div>
          <div>
            予約状況: {item.capacity}/{item.remainingSlots}
          </div>
        </div>
      ))}
    </div>
  )
}

export const Page = () => {
  const [lessonsPromise] = useState(() => getLessons())

  const mutation = (e: ChangeEvent) => {
    e.preventDefault()

    createLesson({
      name: "q",
      instructor: "a",
      startsAt: "",
      endsAt: "",
      capacity: 1,
      description: "",
    })
      .then(alert)
      .catch((err) => alert(JSON.stringify(err)))
  }

  return (
    <div className={container}>
      <header className="">
        <h1>lesson</h1>
      </header>
      <div>this is lessons</div>

      <div className={mainContent}>
        <form onSubmit={mutation} className={form}>
          <label className={label}>
            name
            <input className={input} />
          </label>

          <label className={label}>
            instructor
            <input className={input} />
          </label>

          <label className={label}>
            startsAt
            <input className={input} />
          </label>

          <label className={label}>
            endsAt
            <input className={input} />
          </label>

          <label className={label}>
            capacity
            <input className={input} />
          </label>

          <label className={label}>
            description
            <input className={input} />
          </label>

          <button type="submit" className={button}>
            submit
          </button>
        </form>

        <Suspense fallback={<div>Loading...</div>}>
          <LessonList promise={lessonsPromise} />
        </Suspense>
      </div>
    </div>
  )
}

const container = vstack({ h: "full" })
const mainContent = grid({ gridAutoFlow: "column" })

const form = grid({})

const label = grid({})
const input = css({ border: "solid 1px" })

const button = css({ border: "solid 1px" })
