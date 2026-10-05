# Session 19 - Cloud and Terraform in Action

**Name:** Rajasurya J

**Enrollment number:** 24BCS10086

## Objective

I used Terraform to deploy a VPC, EC2 web server and private S3 bucket in `ap-southeast-2`.
The nginx endpoint returned HTTP 200 with the configured page. EC2 system and instance
checks passed, and I checked encrypted EBS storage, IMDSv2 and restricted HTTP ingress.
After testing, I destroyed the twelve resources.

## Architecture

```text
Terraform → VPC → two public subnets → route table / Internet Gateway → Security Group → EC2
         └─ private encrypted S3 bucket
```

## Environment

- Host: macOS arm64
- Terraform: 1.16.4; AWS provider: 6.67.0
- AWS CLI: 2.36.41; profile: `devops-homework`
- Selected Region: `ap-southeast-2`

Terraform commands run on the Mac; the resources run in AWS. State, saved plans,
authentication caches and `.terraform/` stay outside Git.

## Configuration

[cloud-project/](cloud-project/) contains the provider configuration, resources, typed variables,
outputs and configuration tests.

The configuration creates two public subnets in different availability zones, an Internet
Gateway, a public route table and associations, an HTTP Security Group, an Amazon Linux
EC2 instance and private encrypted S3 storage. The instance uses an AMI data source,
encrypted EBS, IMDSv2 and an nginx user-data script. Its `t3.micro` CPU credit mode is Standard.

HTTP is restricted to `web_cidr`. Replace the documentation address in
`terraform.tfvars.example` with the intended client IPv4/32 and choose a unique bucket name.
No SSH ingress is needed. The final project reuses this configuration as a local module
with different resource names and a separate Terraform state.

## Setup and deployment

I checked that the project was on an ACTIVE FREE plan with remaining credits before
provisioning. Usage consumes the project's credits under the [AWS Free plan](https://aws.amazon.com/free/free-tier-faqs/).

```bash
export AWS_PROFILE=devops-homework AWS_REGION=ap-southeast-2
aws freetier get-account-plan-state --region ap-southeast-2 --profile devops-homework
cd cloud-project
terraform init -input=false
terraform fmt -check
terraform validate
terraform test
terraform plan -input=false -var-file=/tmp/devops-audit-20261005/hw19-vars.json -out=homework.tfplan
terraform apply -input=false homework.tfplan
terraform show
terraform output
terraform state list
```

The local variable file supplied `region=ap-southeast-2`,
`bucket_name=rajasurya-24bcs10086-hw19-20261005` and my public IPv4/32 for `web_cidr`.
For another run, copy `terraform.tfvars.example` to `terraform.tfvars` and set those values.

[Validation](evidence/validation.txt) and [configuration tests](evidence/mock-tests.txt)
show the setup checks. `terraform test` uses a mock provider to check configuration assertions.

## Verification

The plan and apply created twelve resources. The web server returned the configured
nginx page with HTTP 200. EC2 system and instance checks passed; the root EBS volume was
encrypted and IMDSv2 required tokens. The Security Group allowed HTTP only from my IPv4/32.

- [Terraform plan](evidence/aws-plan.txt)
- [Apply output](evidence/aws-apply.txt)
- [Resource details](evidence/aws-show.txt)
- [Terraform outputs](evidence/aws-outputs.json)
- [State resource list](evidence/aws-state-resources.txt)
- [AWS resource checks](evidence/aws-resource-verification.json)
- [HTTP response](evidence/aws-http.txt)

## Cleanup

```bash
terraform destroy -auto-approve -input=false -var-file=/tmp/devops-audit-20261005/hw19-vars.json
terraform state list
```

Terraform destroyed all twelve resources.
The [final state list](evidence/aws-state-after-destroy.txt) was empty, and
[the AWS inventory check](evidence/aws-cleanup-verification.json) confirmed removal.
[Destroy output](evidence/aws-destroy.txt)

## Troubleshooting

The first plan attempt could not find AWS credentials. After browser authentication with
`devops-homework`, planning and deployment succeeded.
[Identity check](evidence/aws-blocker.txt) · [Plan error](evidence/real-plan-attempt.txt)

![Terraform validation and credential setup](images/01-terraform-validation.png)

## Screenshots

![Cloud apply and Terraform state](images/02-aws-cloud-apply.png)
![EC2, S3 and HTTP checks](images/03-aws-cloud-verification.png)
![Cloud destroy and empty state](images/04-aws-cloud-destroy.png)
