terraform {
  required_version = ">= 1.9"

  required_providers {
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.13"
    }
  }
}

provider "neon" {
  api_key = var.neon_api_key
}
