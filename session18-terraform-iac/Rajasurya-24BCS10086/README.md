# Session 18 - Terraform and Infrastructure as Code

**Name:** Rajasurya J

**Enrollment number:** 24BCS10086

## Objective

I used Terraform to create a private S3 bucket in `ap-southeast-2`, with versioning,
AES256 encryption and all four public-access blocks enabled. I checked the bucket settings
and then removed the four resources with Terraform.

## Architecture

```text
Terraform → private S3 bucket → versioning / encryption / public-access block
```

## Environment

- Host: macOS arm64
- Terraform: 1.16.4; AWS provider: 6.67.0
- AWS CLI: 2.36.41; profile: `devops-homework`
- Selected Region: `ap-southeast-2`

Terraform commands run on the Mac; the resources run in AWS. State, saved plans,
authentication caches and `.terraform/` stay outside Git.

## Configuration

[terraform-s3-demo/](terraform-s3-demo/) contains the provider configuration, resources, typed variables,
outputs and configuration tests.

Resource references connect the bucket to its versioning, encryption and public-access
configuration. `force_destroy` is disabled, so objects must be removed before deleting the bucket.
`terraform.tfvars` contains the Region and bucket name.

## Setup and deployment

I checked that the project was on an ACTIVE FREE plan with remaining credits before
provisioning. Usage consumes the project's credits under the [AWS Free plan](https://aws.amazon.com/free/free-tier-faqs/).

```bash
export AWS_PROFILE=devops-homework AWS_REGION=ap-southeast-2
aws freetier get-account-plan-state --region ap-southeast-2 --profile devops-homework
cd terraform-s3-demo
terraform init -input=false
terraform fmt -check
terraform validate
terraform test
terraform plan -input=false -out=homework.tfplan
terraform apply -input=false homework.tfplan
terraform show
terraform output
terraform state list
```

[Validation](evidence/validation.txt) and [configuration tests](evidence/mock-tests.txt)
show the setup checks. `terraform test` uses a mock provider to check configuration assertions.

## Verification

The plan and apply created four resources. The S3 checks returned the bucket location
`ap-southeast-2`, versioning `Enabled`, encryption `AES256`, and `true` for each public-access block.

- [Terraform plan](evidence/aws-plan.txt)
- [Apply output](evidence/aws-apply.txt)
- [Resource details](evidence/aws-show.txt)
- [Terraform outputs](evidence/aws-outputs.json)
- [State resource list](evidence/aws-state-resources.txt)
- [AWS resource checks](evidence/aws-resource-verification.json)

## Cleanup

```bash
terraform plan -destroy -input=false -out=destroy.tfplan
terraform apply -input=false destroy.tfplan
terraform destroy -auto-approve -input=false
terraform state list
```

The destroy plan removed all four resources. A final `terraform destroy` check reported
zero remaining resources.
The [final state list](evidence/aws-state-after-destroy.txt) was empty, and
[the AWS inventory check](evidence/aws-cleanup-verification.json) confirmed removal.
[Destroy output](evidence/aws-destroy.txt)

## Troubleshooting

The first plan attempt could not find AWS credentials. After browser authentication with
`devops-homework`, planning and deployment succeeded.
[Identity check](evidence/aws-blocker.txt) · [Plan error](evidence/real-plan-attempt.txt)

![Terraform validation and credential setup](images/01-terraform-validation.png)

## Screenshots

![S3 apply and outputs](images/02-aws-s3-apply.png)
![S3 settings and Terraform outputs](images/03-aws-s3-verification.png)
![S3 destroy and empty state](images/04-aws-s3-destroy.png)

## Task 2: AWS services research

- [IAM - governance](aws-services/01-iam/README.md)
- [EC2 - compute](aws-services/02-ec2/README.md)
- [S3 - storage](aws-services/03-s3/README.md)
- [VPC - networking](aws-services/04-vpc/README.md)
- [DynamoDB and RDS](aws-services/05-dynamodb-rds/README.md)
