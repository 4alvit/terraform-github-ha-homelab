variable "github_token" {
  description = "GitHub credential authorized to administer repositories in ha-homelab. Store only as a sensitive HCP Terraform workspace variable."
  type        = string
  sensitive   = true
}

variable "billing_email" {
  description = "Existing organization billing email; preserve its value and store it only as a sensitive HCP Terraform variable."
  type        = string
  sensitive   = true
}
