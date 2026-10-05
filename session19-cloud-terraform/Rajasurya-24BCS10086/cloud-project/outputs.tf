output "vpc_id" { value = aws_vpc.main.id }
output "subnet_ids" { value = aws_subnet.public[*].id }
output "instance_id" { value = aws_instance.web.id }
output "web_url" { value = "http://${aws_instance.web.public_ip}" }
output "bucket_name" { value = aws_s3_bucket.artifacts.bucket }
