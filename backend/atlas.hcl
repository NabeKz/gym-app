env "neon" {
  src     = "file://db/schema.hcl"
  url     = getenv("DATABASE_URL")
  dev     = getenv("DEV_DATABASE_URL")
  schemas = ["public", "app"]
}
