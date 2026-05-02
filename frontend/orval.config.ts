import { defineConfig } from "orval"

export default defineConfig({
  gymApp: {
    input: "../docs/openapi.yaml",
    output: {
      baseUrl: "http://localhost:8000",
      target: "src/shared/generated/openapi.gen.ts",
      client: "fetch",
      clean: true,
    },
  },
})
