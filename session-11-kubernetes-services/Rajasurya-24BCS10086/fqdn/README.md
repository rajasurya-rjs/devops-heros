# Session 11 - FQDN

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

## What is an FQDN?

A fully qualified domain name identifies a host or service through its complete DNS hierarchy.
For a Kubernetes Service the conventional name is `<service>.<namespace>.svc.<cluster-domain>`.
The default cluster domain in this lab is `cluster.local`.

`web-service-clusterip.default.svc.cluster.local` identifies the ClusterIP Service from the existing hands-on lab.
Within `default`, `web-service-clusterip` works because the Pod resolver searches its namespace.
From another namespace, use `web-service-clusterip.default`, or the full name.
A final dot makes the name absolute and avoids search suffixes.

## Pod-to-Service communication

A Pod asks its configured DNS server for the Service name. CoreDNS returns the Service ClusterIP;
the Service dataplane then forwards the connection to a ready backend Pod.
For a headless Service, DNS returns backend Pod addresses instead of a virtual IP.
StatefulSet Pod names can be addressed as `<pod>.<headless-service>.<namespace>.svc.cluster.local`.

## Existing execution evidence

The original commands, actual DNS responses, resolver configuration and screenshot are preserved in
[Task 8 - FQDN and CoreDNS](../README.md#task-8--fqdn--coredns-deep-dive).
The comparison of Deployment and StatefulSet identities is in [Task 9](../README.md#task-9--pod-identity-deployment-vs-statefulset).

[Service DNS documentation](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
