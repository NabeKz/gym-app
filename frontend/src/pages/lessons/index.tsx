import { vstack } from "styled-system/patterns"

export const Page = () => {
  return (
    <div className={container}>
      <div>aaa</div>
    </div>
  )
}

const container = vstack({
  paddingBlock: "sm",
})
