# Session 17 - Complete CI/CD and DevSecOps

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

## Demo project

This session uses the [Operations Notes application](../../final-devops-project/application/app.py),
[Dockerfile](../../final-devops-project/docker/Dockerfile), [Helm chart](../../final-devops-project/helm/ops-notes/)
and [executable workflow](../../.github/workflows/devops-homework.yml) built for the final project.
I used the same application for testing, security scanning, image builds and deployment.

## Environment

Local testing runs on the macOS Apple Silicon host. Docker builds run in Docker Desktop's Linux VM.
Local Kubernetes uses the dedicated `devops-completion` vfkit minikube VM. GitHub Actions runs on GitHub-hosted Ubuntu runners.
The CD job deploys to a disposable kind cluster on the Ubuntu runner.

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
`--ignore-unfixed` excludes findings without an available fix.

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

Run these from the repository root after installing the scanners. All nine API tests passed locally and
in GitHub Actions. Local scanner output is retained in [security-local.txt](../../final-devops-project/evidence/security-local.txt).
The local Trivy database download stalled; the complete image scans succeeded on the remote Ubuntu runner.

## Successful pipeline execution

[Successful run](https://github.com/rajasurya-rjs/devops-heros/actions/runs/37272214475) built and scanned both amd64 and arm64 images, pushed their SHA-tagged
versions and the multi-platform manifest to GHCR, then deployed the tested amd64 artifact with Helm to kind.
The three jobs (`test-security`, `build-push`, `deploy-kubernetes`) all finished with `success`.
The local Apple Silicon deployment imports the tested arm64 image artifact from this same run.

- [Run metadata](../../final-devops-project/evidence/ci-run.json) and [runner output](../../final-devops-project/evidence/ci-run.log)
- [Unit tests](../../final-devops-project/evidence/tests.txt), [SAST](../../final-devops-project/evidence/sast.txt), [SCA](../../final-devops-project/evidence/sca.txt), [secret scan](../../final-devops-project/evidence/secrets.txt)
- [amd64 image scan](../../final-devops-project/evidence/image-scan.txt), [arm64 image scan](../../final-devops-project/evidence/image-scan-arm64.txt), [Kubernetes deployment](../../final-devops-project/evidence/ci-deployment.txt)

The initial image gate correctly rejected four fixable HIGH findings in unused installer dependencies.
The [failed gate log](../../final-devops-project/evidence/pipeline-failures/security-gate.txt) shows those findings.
Removing unused pip/setuptools/wheel and their bundled packages from the runtime image fixed those findings;
the gate remained enabled. A first setup-tool failure was corrected by selecting the verified available
setup-trivy action tag. The HIGH/CRITICAL threshold stayed the same.

## Screenshots

![GitHub Actions run](../../final-devops-project/images/02-ci-success.png)
![Security and deployment report](../../final-devops-project/images/05-security-gate.png)
