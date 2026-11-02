# Adopt the existing Home Studio association without replacing the secret or
# its selected-repository list. Canonical state ownership was checked first.
import {
  to = github_actions_organization_secret_repository.public_review_bot_access["home-studio"]
  id = "BOT_PAT:1414876449"
}
