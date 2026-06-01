resource "neon_project" "gym_app" {
  name                      = "gym-app"
  org_id                    = "org-red-thunder-73203735"
  region_id                 = var.neon_region
  history_retention_seconds = 21600
}

resource "neon_role" "app" {
  project_id = neon_project.gym_app.id
  branch_id  = neon_project.gym_app.default_branch_id
  name       = "gym_app_user"
}

resource "neon_database" "gym_app" {
  project_id = neon_project.gym_app.id
  branch_id  = neon_project.gym_app.default_branch_id
  name       = "gym_app"
  owner_name = neon_role.app.name
}
