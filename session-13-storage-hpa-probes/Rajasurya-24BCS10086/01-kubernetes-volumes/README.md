# Session 13 - Kubernetes Volumes

**Name:** Rajasurya J

**Enrollment number:** 24BCS10086

| Volume concept | Lifetime and purpose | Lab example |
|---|---|---|
| emptyDir | Created for a Pod; survives container restarts, disappears when the Pod is removed. | `/scratch/student.txt` in `volume-demo.yaml`. |
| hostPath | Mounts a path on the Kubernetes node; binds the workload to node-local data. | `/tmp/devops-hw13` in the Linux VM, mounted at `/host-demo`. |
| PersistentVolume | A cluster storage resource with capacity, access mode and lifecycle policy. | PV dynamically created for the mini-project claim. |
| PersistentVolumeClaim | A namespace-scoped request for storage; the Pod mounts its bound volume. | `web-data`, 256Mi, ReadWriteOnce. |
| StorageClass | Describes the provisioner and storage policy for claims. | minikube's `standard` class. |
| Dynamic provisioning | Provisioner creates a PV to satisfy a PVC, without manually writing a PV first. | `kubectl get sc,pv,pvc` output in the evidence. |

## Practical examples

[volume-demo.yaml](volume-demo.yaml) writes a student file to emptyDir and a separate marker to hostPath.
The hostPath refers to the minikube VM filesystem, not a folder directly on macOS.
The mini project mounts the claim at `/data`, writes the enrollment number, deletes a Pod and reads
it from its replacement. The data survives because the PVC/PV are independent of the Pod.

[Commands, actual output and screenshots](../README.md) document these executions.

hostPath grants access to node files and is usually inappropriate for portable application data.
A production StorageClass commonly uses a CSI provisioner; minikube's local provisioner is a lab implementation.
A PV's reclaim policy determines what happens after its claim is removed, so deleting a Pod and deleting a
PVC are different operations.

[Official storage documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
