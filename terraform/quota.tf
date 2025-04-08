resource "nomad_quota_specification" "app_team" {
  name        = "app-team"
  description = "app team quota"

  limits {
    region = "global"

    region_limit {
      cpu       = 512
      memory_mb = 512
    }
  }
}

resource "nomad_namespace" "app" {
  name        = "app"
  description = "App team environment."
  quota       = nomad_quota_specification.app_team.name
}
