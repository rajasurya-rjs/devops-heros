# EC2 - Compute

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

EC2 supplies virtual machines. The instance type sets CPU, memory and network capacity; an AMI supplies the operating-system and software image. Match the AMI architecture to the instance type.

| Concept | Meaning |
|---|---|
| Key pair | Public key on the instance, private key retained by the operator for supported login workflows. |
| Security Group | Stateful network rules attached to an instance network interface. |
| EBS | Persistent block storage; snapshots support backup and recovery. |
| Private IP | Used inside the VPC or connected private networks. |
| Public IP | Internet-routable address; routes and security rules must also permit access. |
| Lifecycle | Pending → Running → Stopping/Stopped → Shutting-down/Terminated. |

Stopping an EBS-backed instance differs from terminating it: termination can delete its root volume according to the delete-on-termination setting. Instance-store data is ephemeral. EC2 is suitable for web servers, build agents and software needing OS control.

The Session 19 project selects Amazon Linux through an AMI data source and provisions a web instance with encrypted EBS and IMDSv2 required. Its HTTP rule is limited to a configurable client CIDR; it opens no SSH port.

[Official AWS documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
