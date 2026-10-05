# S3 - Storage

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

S3 is object storage. A bucket is the container; an object consists of content, a key and metadata. Object keys identify data without requiring a filesystem directory hierarchy.

| Feature | Use |
|---|---|
| Storage classes | Standard for frequently accessed objects; Intelligent-Tiering or infrequent-access/archive classes for suitable access patterns. |
| Versioning | Retain multiple versions to recover from accidental replacement or deletion. |
| Lifecycle | Move eligible objects to another class or expire them using configured rules. |
| Encryption | Server-side encryption protects stored content; SSE-S3 uses S3-managed keys, SSE-KMS uses KMS keys. |
| Bucket policy | Resource-based JSON permissions; combine with IAM and Block Public Access. |

Use S3 for backups, CI artifacts and static assets. Public access should be intentional; an HTTP application and a private artifact bucket have different access requirements. Archive classes have retrieval and minimum-duration considerations.

The S3 demo enables versioning, SSE-S3 and all four public-access blocks. `force_destroy=false` avoids silently deleting bucket objects during Terraform cleanup.

[Official AWS documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
