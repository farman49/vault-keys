provider "aws" {
  region = "us-east-1"  # Update with your desired AWS region
}

resource "aws_iam_access_key" "test" {
  user = "admin"  # Replace with the name of your existing IAM user

  lifecycle {
    create_before_destroy = true  # Ensures the old access key is deleted only after the new one is created
  }
}

output "access_key" {
  value = aws_iam_access_key.test.id
}

output "secret_key" {
  value = aws_iam_access_key.test.secret
  sensitive = true
}
output "sensitive_secret_key" {
  value = aws_iam_access_key.test.secret
}