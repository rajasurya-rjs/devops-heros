# Recording interruption diagnosis and repair — 16 October 2026

These files record actual checks against the homework EKS cluster, except for the
explicitly labelled local subprocess tests. They do not replace the student's video.

## Observed cause

`grafana-before.json` records Grafana's real `OOMKilled` termination, exit code 137,
at 13:01:40 UTC (18:31:40 IST). Its old container memory limit was 512 MiB. The
local port-forward then lost its connection. The previous helper exited and
terminated its three other forwards as well.

## Applied repair

- Helm release `notes-monitoring`, revision 3, deployed to `project-monitoring`.
- Grafana requests 256 MiB, has a 1 GiB hard container limit and a 768 MiB
  `GOMEMLIMIT` soft target. The existing worker had enough free memory and scheduler
  capacity; no worker, instance, LoadBalancer, paid plan or advanced feature was added.
- Grafana uses a Recreate update strategy to avoid needing space for two Grafana
  pods on the single worker during an intentional update. Planned updates can cause
  temporary dashboard downtime and should be completed before the demonstration.
- The local helper supervises each tunnel independently, retries exited connections,
  checks HTTP health and replaces unresponsive tunnels. A tunnel failure no longer
  deliberately shuts down its peers. Port-conflict checks and a process lock prevent
  a second helper from replacing existing listeners.

The Go target is soft and does not bound every process's memory. See the primary
[Go memory-limit guidance](https://go.dev/doc/gc-guide#Memory_limit). This is a
mitigation based on observed memory use, not a guarantee that Grafana cannot fail.

## Verification

- `local-recovery-tests.txt`: three standard-library integration tests using local
  fake services. They exercise exited and hung connection recovery, peer isolation,
  cleanup, occupied-port refusal and failed-startup refusal. CI now runs these tests.
- Helm lint and server-side upgrade dry run passed before the actual upgrade.
- `live-recovery.log` / `live-recovery.json`: the real helper reached HTTP 200 on
  all four EKS endpoints. The test deliberately terminated only its own Grafana
  forwarding process after 20 seconds. Grafana reconnected automatically by the
  29.4-second sample. The three peers stayed HTTP 200 with unchanged forwarding
  PIDs throughout the 180.2-second observation. The test then stopped its own helper.
- `browser-check.json` and `../../images/recording-grafana-stability.png`: a real
  isolated Chrome check after reconnection, with populated panels and five normal
  EKS app reloads. An earlier browser navigation during the deliberately interrupted
  tunnel failed with connection refused; the subsequent check passed after recovery.
- `live-monitoring.json`: both backend scrape targets UP, and all four provisioned
  panel expressions returned actual data through Grafana's Prometheus datasource.
- `memory-before.json` / `monitoring-after.json`: genuine worker memory readings,
  applied settings and post-update monitoring readiness/restart counts.

The ACTIVE Free plan and remaining credits were verified before the Helm change.
No credentials, private inputs or Terraform state are included here.

## Recording handoff

Restart `./scripts/recording-up.sh` in the student's own Terminal tab to load the
new supervisor, wait for Ready and refresh the existing browser pages. Keep that
terminal and the browser helper running. Rehearse first and keep the laptop awake
with a stable network. A single-worker cluster and local forwarding cannot promise
uninterrupted service; this short test does not establish long-term availability.

The mandatory student video, actual eventual Terraform destroy completion proof
and student form submission remain separate outstanding submission steps.
