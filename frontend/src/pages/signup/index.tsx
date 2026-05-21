import type { ChangeEvent } from "react"
import { css } from "styled-system/css"
import { grid, vstack } from "styled-system/patterns"

const onSubmit = (e: ChangeEvent) => {
  e.preventDefault()
}

export const Page = () => {
  return (
    <form className={styles.form} onSubmit={onSubmit}>
      <div className={styles.body}>
        <label className={styles.label}>
          id
          <input type="text" required className={styles.input} />
        </label>
        <label className={styles.label}>
          password
          <input type="password" required className={styles.input} />
        </label>
      </div>
      <div className={grid({})}>
        <button type="submit" className={styles.button}>
          submit
        </button>
      </div>
    </form>
  )
}

const styles = {
  form: vstack({
    display: "grid",
    gap: "lg",
  }),
  body: vstack({}),
  buttonContainer: grid({}),
  button: css({
    padding: "xs",
    border: "thin solid black",
  }),
  label: grid({}),
  input: css({
    border: "thin solid black",
    padding: "sm",
  }),
} as const
