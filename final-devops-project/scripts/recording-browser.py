#!/usr/bin/env python3
"""Open real EKS walkthrough pages in an isolated browser; credentials stay in memory."""
import base64
import json
from pathlib import Path
import subprocess
from playwright.sync_api import sync_playwright

kubeconfig_path = str(Path.home() / ".local/share/devops-homework/capstone/kubeconfig")
subprocess.run(["python3", "scripts/aws-guard.py", "--kubeconfig", kubeconfig_path, "--check-client-ip"], check=True)
kube = ["kubectl", "--kubeconfig", kubeconfig_path, "--context", "devops-homework-eks"]
raw = subprocess.check_output(kube + ["get", "secret", "argocd-initial-admin-secret", "-n", "argocd", "-o", "json"], text=True)
password = base64.b64decode(json.loads(raw)["data"]["password"]).decode()

with sync_playwright() as playwright:
    browser = playwright.chromium.launch(channel="chrome", headless=False,
        args=["--host-resolver-rules=MAP notes.aws.project.local 127.0.0.1"])
    context = browser.new_context(viewport={"width": 1500, "height": 1000})
    page = context.new_page()
    page.goto("http://127.0.0.1:48080", wait_until="domcontentloaded")
    page.locator('input[name="username"]').fill("admin")
    page.locator('input[name="password"]').fill(password)
    page.get_by_role("button", name="SIGN IN").click()
    page.get_by_text("operations-notes", exact=False).first.wait_for(timeout=60000)
    page.goto("http://127.0.0.1:48080/applications/argocd/operations-notes?view=tree")
    for url in ["http://notes.aws.project.local:28080", "http://127.0.0.1:49091/targets",
                "http://127.0.0.1:43001/d/ops-three-tier?orgId=1&from=now-15m&to=now"]:
        tab = context.new_page()
        tab.goto(url, wait_until="domcontentloaded")
    print("Recording browser is open. It uses the real EKS Ingress and monitoring services.")
    input("Press Enter here after recording to close this isolated browser. ")
    browser.close()
