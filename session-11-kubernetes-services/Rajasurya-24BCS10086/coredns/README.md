# Session 11 - CoreDNS

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

## Purpose and Service discovery

CoreDNS is Kubernetes' DNS server. The `kubernetes` plugin watches Service and endpoint data through
the API and answers cluster-domain queries. Ordinary Services resolve to their ClusterIP;
headless Services resolve to ready backend addresses. ExternalName Services return a CNAME.
The `kube-dns` Service gives Pods a stable DNS-server address.

## Query resolution and configuration

The Pod's `/etc/resolv.conf` contains its nameserver, namespace search suffixes and `ndots` setting.
The resolver tries names according to that configuration. CoreDNS answers names in `cluster.local`
locally and its `forward` plugin sends external queries to upstream resolvers.
The Corefile is stored in the `coredns` ConfigMap in `kube-system`.
Common plugins include `errors`, `health`, `ready`, `kubernetes`, `forward`, `cache`, `loop`, `reload` and `loadbalance`.

## Troubleshooting commands

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get svc kube-dns -n kube-system
kubectl get configmap coredns -n kube-system -o yaml
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl exec <client-pod> -- cat /etc/resolv.conf
kubectl exec <client-pod> -- nslookup <service>.<namespace>.svc.cluster.local
kubectl get endpointslices -l kubernetes.io/service-name=<service>
```

Check the Service spelling and namespace first, then DNS Pods, Service endpoints,
resolver configuration, and network access to UDP/TCP 53. An IP connection succeeding while
name resolution fails narrows the problem to DNS. A Service resolving correctly but having
no ready endpoints points to selectors or readiness instead.

## Commands and output

[Task 8](../README.md#task-8--fqdn--coredns-deep-dive) contains the CoreDNS, FQDN and `ndots`
commands, results and [screenshot](../images/08-fqdn-coredns.png).

[CoreDNS debugging guide](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
