#!/usr/bin/env python3
"""Fail closed unless this is the homework project with an ACTIVE Free plan and credits."""
import json
import subprocess

PROFILE = "devops-homework"
REGION = "ap-southeast-2"
PROJECT_ID = "089540175430"


def check():
    def aws(*args):
        return json.loads(subprocess.check_output(
            ["aws", *args, "--region", REGION, "--profile", PROFILE, "--output", "json"],
            text=True,
        ))

    identity = aws("sts", "get-caller-identity")
    plan = aws("freetier", "get-account-plan-state")
    if identity["Account"] != PROJECT_ID or plan["accountId"] != PROJECT_ID:
        raise SystemExit("STOP: this is not the homework project.")
    if (plan["accountPlanType"] != "FREE" or plan["accountPlanStatus"] != "ACTIVE"
            or float(plan["accountPlanRemainingCredits"]["amount"]) <= 0):
        raise SystemExit("STOP: ACTIVE Free plan with available credits could not be verified.")
    return plan


if __name__ == "__main__":
    print(json.dumps(check(), indent=2))
