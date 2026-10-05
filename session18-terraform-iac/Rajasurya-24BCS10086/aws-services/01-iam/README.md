# IAM - Governance

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

IAM governs who may access AWS resources and which actions are permitted. Authentication establishes an identity; authorization evaluates permissions.

| Concept | Meaning and example |
|---|---|
| User | An identity in an account; avoid long-lived access keys when federation is available. |
| Group | A collection of users that receive common policies, such as a developer group. |
| Role | An assumable identity with temporary credentials, used by EC2, CI or cross-account access. |
| Policy | A JSON statement describing allowed or denied actions, resources and conditions. |
| Permission | An effective authorization after applicable policies are evaluated; an explicit deny wins. |
| Least privilege | Grant only the actions and resource scope a job needs. |

Use federation and MFA for people, roles for workloads, and protect the root user. Review unused permissions and access keys. A CI role can be limited to an artifact bucket rather than administrative access. A role's trust policy controls who can assume it; its permissions policy controls what it can do after assumption.

This repository contains no AWS access keys. GitHub's built-in `GITHUB_TOKEN` is scoped per CI job; AWS deployment would need an separately configured identity.

[Official AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
