# Only the reviewed public ZAC93 onboarding images are published here.
# The firmware repository builds the site; Terraform owns the Pages setting.
resource "github_repository_pages" "zac93_installer" {
  repository = github_repository.repositories["zac93-esp32"].name
  build_type = "workflow"

  lifecycle {
    prevent_destroy = true
  }
}
