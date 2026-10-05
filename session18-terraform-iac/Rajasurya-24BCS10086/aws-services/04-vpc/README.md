# VPC - Networking

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

A VPC is a logically isolated AWS network with an IP address range expressed as CIDR. Subnets divide that range and each belongs to one Availability Zone.

| Concept | Responsibility |
|---|---|
| Route table | Choose a destination route and next hop. |
| Internet Gateway | Connect an attached VPC to the internet for appropriately addressed resources. |
| NAT Gateway | Allow suitable outbound connections from private IPv4 resources without exposing them directly. |
| Security Group | Stateful allow rules around network interfaces. |
| Network ACL | Stateless subnet-level allow/deny rules; return traffic requires matching rules. |
| Public subnet | Has a route to an Internet Gateway; the instance also needs a public address and permitted traffic. |
| Private subnet | Has no direct Internet Gateway route; may use NAT or VPC endpoints. |

The homework network uses `10.24.0.0/16`, with two public `/24` subnets in different AZs, an Internet Gateway and route-table associations. A private database would belong in private subnets. A NAT Gateway is omitted from this small public-subnet lab.

[Official AWS documentation](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
