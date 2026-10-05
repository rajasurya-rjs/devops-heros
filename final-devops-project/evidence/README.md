# Logs and reports

| Files | Source / purpose |
|---|---|
| `ci-run.json`, `ci-run.log` | GitHub Actions run metadata and Ubuntu runner logs, downloaded with `gh run view`. |
| `tests.txt`, `sast.txt`, `sca.txt`, `secrets.txt`, `image-scan*.txt`, `ci-deployment.txt` | Actions artifacts for tests, security scans and deployment to kind. |
| `compose.txt`, `monitoring-gitops.txt`, local runtime and troubleshooting logs | Commands run on the Mac against Docker Desktop or the minikube Linux VM. |
| Terraform validation and mock-test logs | Formatting, validation and configuration assertions. |
| `aws-*` | Terraform deployment from the Mac and resource, HTTP and Kubernetes checks in `ap-southeast-2`. |
| `pipeline-failures/` and earlier attempt logs | Errors used to troubleshoot the image security gate, credentials, worker launch and EBS CSI setup. |

The local registry and vulnerability-database downloads stalled. The image was built and
scanned in Actions, then the arm64 artifact was downloaded and loaded for local deployment.
The first AWS worker type was rejected by the Free plan; the node group was updated to an
eligible type. See the main README for the fixes and subsequent results.
