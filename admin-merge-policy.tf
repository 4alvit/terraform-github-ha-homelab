# Organization owners retain a permanent branch-rule bypass, including direct
# pushes and deliberate history corrections. Existing protections still apply
# to other actors; repository roles and automation receive no additional grant.
locals {
  owner_emergency_merge_actor = {
    actor_id    = null
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }
}
