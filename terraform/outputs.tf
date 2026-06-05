output "database_url" {
  description = "DATABASE_URL to set in Fly.io secrets"
  value       = "postgresql://${neon_role.app.name}:${neon_role.app.password}@${neon_project.gym_app.database_host}/${neon_database.gym_app.name}?sslmode=require"
  sensitive   = true
}

# atlas 用 URL は endpoint オプション付き（lib/pq が SNI を送らないため）。
output "atlas_url" {
  description = "Target URL for atlas schema apply (Neon, with endpoint option)"
  value       = "postgresql://${neon_role.app.name}:${neon_role.app.password}@${neon_project.gym_app.database_host}/${neon_database.gym_app.name}?sslmode=require&options=endpoint%3D${local.neon_endpoint_id}"
  sensitive   = true
}

output "dev_database_url" {
  description = "DEV_DATABASE_URL for atlas declarative migration (scratch DB, with endpoint option)"
  value       = "postgresql://${neon_role.app.name}:${neon_role.app.password}@${neon_project.gym_app.database_host}/${neon_database.atlas_dev.name}?sslmode=require&options=endpoint%3D${local.neon_endpoint_id}"
  sensitive   = true
}

