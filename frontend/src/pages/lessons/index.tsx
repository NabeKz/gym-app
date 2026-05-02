import { grid, vstack } from "styled-system/patterns"
import { css } from "styled-system/css"
import { createLesson } from "@/shared/generated/openapi.gen"
import type { ChangeEvent } from "react"

export const Page = () => {
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
    </div>
  )
}

const container = vstack({})

const form = grid({})

const label = grid({})

const input = css({ border: "solid 1px" })

const button = css({ border: "solid 1px" })
