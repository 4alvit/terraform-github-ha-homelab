variable "github_token" {
  description = "GitHub credential authorized to administer repositories in ha-homelab. Store only as a sensitive HCP Terraform workspace variable."
  type        = string
  sensitive   = true
}
