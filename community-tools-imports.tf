# Signed empty bootstrap commits established identities; source enters main
# only through PRs that pass the same source and full-history secret gates.
import {
  for_each = local.community_tools
  to       = github_repository.repositories[each.key]
  id       = each.key
}

import {
  for_each = local.community_tools
  to       = github_branch_default.main[each.key]
  id       = each.key
}

import {
  for_each = local.community_tools
  to       = github_repository_vulnerability_alerts.repositories[each.key]
  id       = each.key
}

import {
  for_each = local.community_tools
  to       = github_repository_dependabot_security_updates.repositories[each.key]
  id       = each.key
}

