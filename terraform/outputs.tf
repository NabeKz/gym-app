output "database_url" {
  description = "DATABASE_URL to set in Fly.io secrets"
  value       = "postgresql://${neon_role.app.name}:${neon_role.app.password}@${neon_project.gym_app.database_host}/${neon_database.gym_app.name}?sslmode=require"
  sensitive   = true
}

