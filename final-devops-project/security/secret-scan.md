# Repository secret review

The capstone source snapshot and full available Git history are scanned with Gitleaks.
The pipeline checks out complete history before scanning. Credentials, `.env`, Terraform
state, authentication caches and kubeconfig remain excluded from Git.

The history audit on 13 October 2026 found seven matches in commit
`fc9aba067db3389ae4b4145bed345f47c7d1566b`, all in the Session 12 classroom Secret
manifests and their explanatory transcripts. Five generic-key matches are base64-encoded
common demonstration passwords. Two matches identify those same YAML documents as
Kubernetes Secrets. These examples are not AWS access keys or tokens and are unrelated
to the randomly generated capstone credentials.

The root `.gitleaksignore` records those seven exact finding fingerprints: commit,
file, rule and line. No directory, AWS-key rule or future credential is broadly excluded.
This preserves genuine completed homework and its history. A clean scan with these
reviewed exceptions means no additional scanner findings; it is not a guarantee that
all possible secrets can be detected.

Run from `final-devops-project`:

```bash
./scripts/scan-secrets.sh
```

Never reuse classroom example passwords for a real deployment. The capstone installers
generate private random passwords and Kubernetes Secrets locally, without committing them.
