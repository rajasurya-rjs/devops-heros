# Recording network recovery — 16 October 2026

The laptop public IP changed from the previously allowed /32. AWS EKS remained
ACTIVE, but its public API access list blocked the new source IP, causing all
localhost cloud forwards to fail. Grafana and Prometheus subsequently showed
zero pod restarts; this incident was a network-access problem.

The ACTIVE FREE plan with credits and the homework project were verified before
updating the private Terraform web_cidr input. The reviewed saved plan permitted
only two in-place access updates: aws_eks_cluster.main and the existing homework
web security group. Actual plan and apply logs are included. The apply completed
with 0 added, 2 changed, 0 destroyed. Private inputs and binary state/plan files
remain outside Git. recovered.json records actual restored HTTP checks, two UP
backend targets and populated responses from all four dashboard queries.

The helper now checks whether the current public IP is allowed before starting.
It allows up to 75 seconds for initial connection negotiation instead of killing
an unready process every three quick failed probes. Established connections still
recover after repeated failures. A single brief failed probe no longer prints a
recovery event; process cleanup covers credential children too. Eight local tests
passed, including delayed startup, process-group cleanup, changed-IP refusal,
credit refusal and existing recovery/occupied-port cases. Cloud access must be
updated through Terraform when the public network changes; the helper does not
silently change AWS access rules. Keep a stable network during the final take.
