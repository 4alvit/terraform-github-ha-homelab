output "organization_url" {
  description = "GitHub organization managed by this workspace."
  value       = "https://github.com/ha-homelab"
}

output "repositories" {
  description = "Managed repositories and their intended visibility."
  value = merge({
    for name, repository in github_repository.repositories : name => {
      html_url   = repository.html_url
      ssh_url    = repository.ssh_clone_url
      visibility = repository.visibility
    }
    }, {
    "home-assistant-public" = {
      html_url   = github_repository.home_assistant_public.html_url
      ssh_url    = github_repository.home_assistant_public.ssh_clone_url
      visibility = github_repository.home_assistant_public.visibility
    }
  })
}
