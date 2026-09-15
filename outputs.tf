output "organization_url" {
  description = "GitHub organization managed by this workspace."
  value       = "https://github.com/ha-homelab"
}

output "repositories" {
  description = "Managed repositories and their intended visibility."
  value = {
    for name, repository in github_repository.repositories : name => {
      html_url   = repository.html_url
      ssh_url    = repository.ssh_clone_url
      visibility = repository.visibility
    }
  }
}
