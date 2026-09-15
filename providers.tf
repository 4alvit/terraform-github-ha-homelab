terraform {
  required_version = ">= 1.15.7, < 2.0"

  cloud {
    organization = "victron-venus"
    workspaces {
      name = "github-ha-homelab-infrastructure"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "ha-homelab"
  token = var.github_token
}
