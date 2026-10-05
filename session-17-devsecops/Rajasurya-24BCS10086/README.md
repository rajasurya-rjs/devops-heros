# Session 17 - Complete CI/CD and DevSecOps

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

## Demo project

This session uses the [Operations Notes application](../../final-devops-project/application/app.py),
[Dockerfile](../../final-devops-project/docker/Dockerfile), [Helm chart](../../final-devops-project/helm/ops-notes/)
and [executable workflow](../../.github/workflows/devops-homework.yml) built for the final project.
It is an original notes application; the class repository was inspected for the expected pipeline concepts.

## Environment

Local testing runs on the macOS Apple Silicon host. Docker builds run in Docker Desktop's Linux VM.
Local Kubernetes uses the existing vfkit minikube VM. GitHub Actions runs on GitHub-hosted Ubuntu runners;
the CD verification job creates a disposable kind cluster. It does not connect to the laptop or an AWS cluster.

## Pipeline

```text
Code → unit/API tests → SAST → SCA → secret scan
     → Docker build → container vulnerability gate → GHCR push
     → Helm deploy to kind → API verification → report artifacts
```

CI checks that the application can be built and tested. CD publishes the tested image and deploys it to
Kubernetes. The workflow defines dependent jobs with `needs`; individual steps share a runner within a job.
`push` to `main` and manual dispatch trigger execution. Pull requests run validation without publishing.

Nine tests cover CRUD, health, metrics, invalid inputs, SQL injection handling and missing routes.
Bandit scans the application source. pip-audit scans runtime requirements: the application has no third-party
runtime packages, so there are no Python runtime dependencies to audit. Gitleaks scans project files with
redaction. Trivy scans image OS and package vulnerabilities and blocks fixable HIGH/CRITICAL findings;
`--ignore-unfixed` is an explicit gate policy, not a claim that every possible CVE is absent.

The build job receives `packages: write`; other jobs use read-only repository permission.
The automatically issued `GITHUB_TOKEN` authenticates GHCR, and its value is never stored in source or evidence.
Images are tagged with the full Git commit SHA. Artifact uploads retain test, security and deployment output.
A generated temporary file creates the demo Kubernetes Secret without printing its value.

## Commands

```bash
python3 -m unittest discover -s final-devops-project/application/tests -v
docker build -t ops-notes:local -f final-devops-project/docker/Dockerfile final-devops-project
bash final-devops-project/security/scan.sh ops-notes:local
```

Run these from the repository root after installing the scanners. The local API tests have passed,
and the Docker image is running in Docker and minikube. [Actual local security output](../../final-devops-project/evidence/security-local.txt)
records the scans performed. Remote pipeline execution is pending this implementation commit; the successful
run URL and screenshots will be added after execution.
