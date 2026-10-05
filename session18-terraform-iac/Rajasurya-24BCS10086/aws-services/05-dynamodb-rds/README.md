# DynamoDB and RDS - Database Services

**Name:** Rajasurya J
**Enrollment number:** 24BCS10086

## DynamoDB

DynamoDB is a managed NoSQL service for key-value and document access. A table contains items; an item contains attributes. The primary key is either a partition key alone or a partition key plus sort key. The partition key supports data distribution; the sort key orders related items sharing a partition key.

Model access patterns before choosing keys: for an incident history, `service_id` can be the partition key and `event_time` the sort key. DynamoDB suits predictable keyed lookups, session state and event metadata. IAM authorizes API access; provisioned or on-demand capacity serves workload needs.

## RDS

RDS manages relational database infrastructure while applications use SQL schemas and queries. Supported database families include PostgreSQL, MySQL, MariaDB, Oracle, SQL Server and Db2; engine and regional availability must be checked for a deployment.

A DB instance runs a selected engine and compute/storage configuration. Place it in an appropriate DB subnet group, restrict Security Groups, encrypt storage and require secure connections. Automated backups and snapshots support recovery. Multi-AZ provides availability; read replicas serve supported read-scaling use cases and are not interchangeable with standby failover instances.

Use RDS for transactional applications with relational constraints and joins; use DynamoDB when keyed access patterns and managed scaling suit the data model. The final project uses SQLite on a PVC for its single-node lab deployment.

[Official AWS documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)

[RDS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
