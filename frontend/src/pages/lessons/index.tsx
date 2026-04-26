import { vstack } from "styled-system/patterns"

export const Page = () => {
  return (
    <div className={container}>
      <header className="">
        <h1>lesson</h1>
      </header>
      <div>this is lessons</div>
    </div>
  )
}

const container = vstack({})
