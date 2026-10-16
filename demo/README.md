# DevSecOps capstone submission

**Rajasurya J · 24BCS10086 · Operations Notes**

- [Presentation — PowerPoint](presentation.pptx)
- [Presentation — PDF](presentation.pdf)
- [Actual AWS cleanup terminal recording — WebM, silent](aws-cleanup.webm)
- [Speaking script with separate SAY, SHOW, TYPE and WAIT cues](RECORDING-SCRIPT.md)
- [Exact recording steps and commands](../final-devops-project/demo/README.md)
- [Instructor’s grading requirements](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/GRADING.md)
- [Complete technical documentation](../final-devops-project/README.md)

## Recorded walkthrough — uploaded

**[Download/watch the complete student recording](https://github.com/rajasurya-rjs/devops-heros/releases/download/capstone-walkthrough-2026-10-16/walkthrough.mp4)** · [Release page](https://github.com/rajasurya-rjs/devops-heros/releases/tag/capstone-walkthrough-2026-10-16)

Recorded by Rajasurya on 16 October 2026. Original, unedited MP4: **33:47**, 2560 × 1600,
H.264 video and AAC stereo audio; 237,471,172 bytes. The release asset belongs to this
same homework repository. Its SHA-256 matches the original local recording:
`c6bbd76f452a8d9c75d2b7bf59f08109147eea8f4377fe96678c6a3e6050ddc7`.

Approximate chapter starts, checked against the recorded screen:

| Time | Demonstration |
|---|---|
| 00:00 | Presentation slides: application, architecture and delivery flow |
| 04:00 | Repository and application source |
| 07:00 | Local application and CRUD |
| 09:00 | Health/tests, Docker source and Compose |
| 14:00 | Live title change, commit and push |
| 16:20 | New GitHub Actions run and workflow gates |
| 18:30 | Successful run and SHA-tagged GHCR images |
| 19:30 | Terraform source, plan and actual saved apply output |
| 25:00 | AWS Console infrastructure |
| 26:00 | Argo CD Synced/Healthy and GitOps change |
| 27:00 | Kubernetes Pods, Services, Ingress and Helm commands |
| 30:30 | Application through the real EKS Ingress |
| 31:50 | Prometheus: both backend targets UP |
| 32:00 | Grafana: populated application panels |
| 32:30 | Documentation and meaningful commit history |

The recording includes real command corrections and waiting for CI; those remain intact.
Its complete video/audio streams decode successfully, and its audio is not silent.
Visual samples were reviewed; this is not a word-for-word transcription or a grading promise.
The actual [live-demo pipeline](https://github.com/rajasurya-rjs/devops-heros/actions/runs/38916498054)
passed for commit `361c4637c8f01f82b6332293c23d8a8da9d5e6ee`.

The deck has twelve slides and speaker notes. Its source counterpart remains under
`final-devops-project/demo/`; these two copies are byte-identical at publication.

## Recording order required by the submission guidelines

1. Present the slides: project and architecture.
2. Show the codebase: folders, key files and design decisions.
3. Trigger a real Git push; show the full GitHub Actions run completing successfully.
4. Show Terraform plan/apply evidence and the AWS VPC/EKS Console.
5. Show the synced Argo CD application and a GitOps change.
6. Show healthy Kubernetes Pods, Services and Ingress.
7. Show Prometheus Targets UP.
8. Show Grafana with live application metrics.

## Deadline wording needs confirmation

The supplied guidelines say **“Sunday, 19 October 2026, 11:59 PM IST.”**
19 October 2026 is Monday; Sunday is 18 October. Until the instructor confirms the
intended date, prepare for the earlier **18 October 2026, 11:59 PM IST** deadline.
This is a precaution, not an asserted change to the official deadline.

The student submits **https://github.com/rajasurya-rjs/devops-heros** through the
[final capstone form](https://forms.gle/XWAP1vAumDJgAPM1A) supplied in the submission guidelines. The agent
never submits the Google Form. AWS teardown completed after recording on 16 October 2026:
[actual completion log](../final-devops-project/evidence/completion/terraform-destroy-complete.txt) and
[screenshot](../final-devops-project/images/terraform-destroy-complete.png). The original attempt removed 26 resources
before an expired request interrupted Internet Gateway deletion; the successful retry
removed the final two resources. Cloud demo URLs are no longer live; the recording
preserves the demonstration and local Compose remains runnable at localhost:13000.
