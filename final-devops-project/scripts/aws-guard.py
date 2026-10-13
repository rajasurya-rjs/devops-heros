#!/usr/bin/env python3
"""Fail closed unless this is the homework project with an ACTIVE Free plan and credits."""
import json
import subprocess
import argparse

PROFILE = "devops-homework"
REGION = "ap-southeast-2"
PROJECT_ID = "089540175430"


def check(kubeconfig_path=None):
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
    if kubeconfig_path:
        cluster = aws("eks", "describe-cluster", "--name", "rajasurya-final-devops")["cluster"]
        config = json.loads(subprocess.check_output([
            "kubectl", "--kubeconfig", kubeconfig_path, "--context", "devops-homework-eks",
            "config", "view", "--minify", "-o", "json",
        ], text=True))
        auth = config["users"][0]["user"].get("exec", {})
        env = {item["name"]: item["value"] for item in auth.get("env", [])}
        if (config["clusters"][0]["cluster"]["server"] != cluster["endpoint"]
                or auth.get("command") != "aws" or env.get("AWS_PROFILE") != PROFILE):
            raise SystemExit("STOP: kubeconfig does not use the homework EKS endpoint and profile.")
    return plan


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--kubeconfig")
    args = parser.parse_args()
    print(json.dumps(check(args.kubeconfig), indent=2))
