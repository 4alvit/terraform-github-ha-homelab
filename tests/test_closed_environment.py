"""Reject live policy drift even when Terraform retains a cached reviewer."""

from copy import deepcopy
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("closed_environment", Path(__file__).resolve().parents[1]
                                             / "scripts/check-closed-environment.py")
checker = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(checker)


class ClosedEnvironmentTests(unittest.TestCase):
    def setUp(self):
        self.environment = {"id": 24760603930, "name": "closed-build", "can_admins_bypass": False,
            "deployment_branch_policy": {"protected_branches": False, "custom_branch_policies": True},
            "protection_rules": [{"type": "required_reviewers", "prevent_self_review": False,
                "reviewers": [{"type": "User", "reviewer": {"id": 272257197, "login": "4alvit"}}]}]}
        self.branches = {"total_count": 1, "branch_policies": [{"id": 63640560, "name": "main", "type": "branch"}]}

    def test_expected_live_policy(self):
        checker.validate_policy(self.environment, self.branches)

    def test_removed_last_reviewer_cannot_reuse_provider_state(self):
        self.environment["protection_rules"] = []
        with self.assertRaisesRegex(ValueError, "required-reviewer"):
            checker.validate_policy(self.environment, self.branches)

    def test_empty_changed_or_additional_reviewers_rejected(self):
        for people in ([], [{"type": "User", "reviewer": {"id": 1, "login": "other"}}],
                       self.environment["protection_rules"][0]["reviewers"] * 2):
            with self.subTest(people=people):
                environment = deepcopy(self.environment)
                environment["protection_rules"][0]["reviewers"] = people
                with self.assertRaises(ValueError):
                    checker.validate_policy(environment, self.branches)

    def test_bypass_branch_or_identity_drift_rejected(self):
        for change in ({"id": 1}, {"can_admins_bypass": True}, {"deployment_branch_policy": None},
                       {"deployment_branch_policy": {"protected_branches": True, "custom_branch_policies": False}}):
            with self.subTest(change=change), self.assertRaises(ValueError):
                checker.validate_policy({**self.environment, **change}, self.branches)
        for change in ({"id": 1}, {"name": "*"}, {"type": "tag"}):
            with self.subTest(change=change), self.assertRaises(ValueError):
                checker.validate_policy(self.environment, {"total_count": 1,
                    "branch_policies": [{**self.branches["branch_policies"][0], **change}]})
        with self.assertRaises(ValueError):
            checker.validate_policy(self.environment, {"total_count": 2,
                "branch_policies": self.branches["branch_policies"] * 2})

    def test_gets_are_anonymous_fixed_and_bounded(self):
        requests = []
        def read(request, timeout):
            requests.append((request, timeout))
            return io.BytesIO(json.dumps(self.environment).encode())
        with patch.object(checker.urllib.request, "urlopen", side_effect=read):
            self.assertEqual(checker.read_public_metadata(), self.environment)
        request, timeout = requests[0]
        self.assertEqual(request.full_url, checker.BASE_URL)
        self.assertEqual(request.get_method(), "GET")
        self.assertIsNone(request.get_header("Authorization"))
        self.assertEqual(timeout, 20)
        with patch.object(checker.urllib.request, "urlopen", return_value=io.BytesIO(b" " * (checker.MAX_BYTES + 1))):
            with self.assertRaisesRegex(ValueError, "bound"):
                checker.read_public_metadata()


if __name__ == "__main__":
    unittest.main()
