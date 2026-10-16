# The user-requested public repository was bootstrapped with its reviewed guide
# and firmware examples. Adopt its existing identity rather than create it again.
# These import blocks do not apply changes until a state-aware plan is approved.
import {
  to = github_repository.repositories["zac93-esp32"]
  id = "zac93-esp32"
}

import {
  to = github_branch_default.main["zac93-esp32"]
  id = "zac93-esp32"
}

import {
  to = github_repository_vulnerability_alerts.repositories["zac93-esp32"]
  id = "zac93-esp32"
}

import {
  to = github_repository_dependabot_security_updates.repositories["zac93-esp32"]
  id = "zac93-esp32"
}
