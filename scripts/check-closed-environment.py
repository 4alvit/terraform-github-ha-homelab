#!/usr/bin/env python3
"""Check the public closed-build policy independently of cached provider state."""

import json
import sys
import urllib.request

BASE_URL = "https://api.github.com/repos/ha-homelab/home-studio/environments/closed-build"
MAX_BYTES = 65536


def read_public_metadata(suffix=""):
    request = urllib.request.Request(BASE_URL + suffix, headers={
        "Accept": "application/vnd.github+json", "User-Agent": "closed-build-policy-check"})
    # Anonymous GETs need no token and never access environment secret endpoints.
    with urllib.request.urlopen(request, timeout=20) as response:
        raw = response.read(MAX_BYTES + 1)
    if len(raw) > MAX_BYTES:
        raise ValueError("Public environment metadata exceeds its bound")
    return json.loads(raw)


def validate_policy(environment, branches):
    if (environment.get("id") != 24760603930 or environment.get("name") != "closed-build"
            or environment.get("can_admins_bypass") is not False
            or environment.get("deployment_branch_policy") != {
                "protected_branches": False, "custom_branch_policies": True}):
        raise ValueError("Closed-build environment identity or branch policy differs")
    reviewers = [rule for rule in environment.get("protection_rules", [])
                 if rule.get("type") == "required_reviewers"]
    if len(reviewers) != 1 or reviewers[0].get("prevent_self_review") is not False:
        raise ValueError("Closed-build required-reviewer policy differs")
    people = reviewers[0].get("reviewers", [])
    if (len(people) != 1 or people[0].get("type") != "User"
            or people[0].get("reviewer", {}).get("id") != 272257197
            or people[0].get("reviewer", {}).get("login") != "4alvit"):
        raise ValueError("Closed-build requires the exact configured reviewer")
    policies = branches.get("branch_policies", [])
    if (branches.get("total_count") != 1 or len(policies) != 1
            or policies[0].get("id") != 63640560 or policies[0].get("name") != "main"
            or policies[0].get("type") != "branch"):
        raise ValueError("Closed-build requires its exact main-only deployment policy")


def main():
    try:
        validate_policy(read_public_metadata(), read_public_metadata("/deployment-branch-policies"))
    except Exception:
        sys.exit("Closed-build live policy verification failed; inspect public environment metadata.")
    print("Closed-build live reviewer and main-only policy verified.")


if __name__ == "__main__":
    main()
