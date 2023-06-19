provider "aws" {
  region = "us-east-1"  # Update with your desired AWS region
}

# provider "vault" {
#   address = "http://vault.example.com"  # Replace with the address of your Vault server
#   token   = "your_vault_token"  # Replace with your Vault token
# }

resource "aws_iam_access_key" "test" {
  user = "admin"  # Replace with the name of your existing IAM user

  lifecycle {
    create_before_destroy = true  # Ensures the old access key is deleted only after the new one is created
  }

  # provisioner "local-exec" {
  #   command = <<EOF
  #     vault kv put secret/my/path/access_credentials access_key=${aws_iam_access_key.test.id} secret_key=${aws_iam_access_key.test.secret} 
  #   EOF
  # }  
}

output "access_key" {
  value = aws_iam_access_key.test.id
}

output "secret_key" {
  value     = aws_iam_access_key.test.secret
  sensitive = true
}

#output "sensitive_secret_key" {
  #value = aws_iam_access_key.test.secret
#}
