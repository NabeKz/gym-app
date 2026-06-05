locals {
  # Neon は SNI で接続先エンドポイントを判別するが、atlas が使う lib/pq は
  # sslmode=require だと SNI を送らない。そこで endpoint id を options で明示する
  # （db.gleam がアプリ側でやっているのと同じ手法）。host の先頭ラベルから
  # "-pooler" を除いたものが endpoint id。
  neon_endpoint_id = trimsuffix(split(".", neon_project.gym_app.database_host)[0], "-pooler")
}

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

# atlas が宣言的マイグレーションの差分計算に使うスクラッチ DB。
# 本番(gym_app)とは別データベースにすることで、dev で public/app スキーマを
# 作り直しても本番に影響しない。ローカル docker のブリッジ問題も回避できる。
resource "neon_database" "atlas_dev" {
  project_id = neon_project.gym_app.id
  branch_id  = neon_project.gym_app.default_branch_id
  name       = "atlas_dev"
  owner_name = neon_role.app.name
}
