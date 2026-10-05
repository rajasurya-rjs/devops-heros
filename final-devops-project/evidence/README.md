# Evidence provenance

`ci-run.json` and `ci-run.log` are fetched from GitHub Actions using `gh run view`.
`tests.txt`, `sast.txt`, `sca.txt`, `secrets.txt`, `image-scan*.txt` and `ci-deployment.txt`
are genuine downloaded GitHub Actions artifacts. They record remote Ubuntu runner execution,
not commands run directly on the Mac or on AWS.

The local `compose.txt`, `monitoring-gitops.txt` and troubleshooting logs come from real
commands run on the Mac against Docker Desktop or the named minikube Linux VM.
Terraform validation and mock-provider tests create no real cloud resources.

The initial local vulnerability database download and Docker registry metadata requests
stalled. Local attempts are preserved; the image was built and scanned successfully on
GitHub Actions. The tested arm64 artifact was downloaded and loaded locally for deployment.

Screenshots capture actual browser pages or live ttyd terminal sessions using Chromium.
Native macOS screen capture failed because no capturable display was available. No terminal
output or browser UI was fabricated. Saved-log excerpts in terminal captures are labelled
by the actual commands that display those files.

Terminal and runner logs retain their original spacing; `.gitattributes` scopes whitespace checks
accordingly. Application, shell, YAML, Terraform and Markdown changes remain whitespace checked.
