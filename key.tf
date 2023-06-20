provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# provider "vault" {
#   address = "http://vault.example.com"  # Replace with your Vault address
#   token   = "your-vault-token"  # Replace with your Vault token
# }

data "aws_iam_user" "rohan" {
  user_name = "rohan"
}

data "aws_iam_user" "admin" {
  user_name = "admin"
}

locals {
  existing_users = ["rohan", "admin"]
}

resource "null_resource" "rotate_access_key" {
  for_each = toset(local.existing_users)

  provisioner "local-exec" {
    command = <<EOF
      access_key_metadata=$(aws iam list-access-keys --user-name ${each.key} --query "AccessKeyMetadata[1]")
      
      if [ "$access_key_metadata" != "null" ]; then
        access_key_age=$(($(date +%s) - $(date --date=$(echo $access_key_metadata | jq -r '.CreateDate') +%s)))
        if (( $access_key_age / 86400 > 80 )); then
          aws iam delete-access-key --access-key $(echo $access_key_metadata | jq -r '.AccessKeyId') --user-name ${each.key}
          aws iam create-access-key --user-name ${each.key}
          
          # vault write secret/aws_access_keys/${each.key} \
          #   access_key=$($(aws iam list-access-keys --user-name ${each.key} --query "AccessKeyMetadata[0].AccessKeyId" --output text) 2>/dev/null) \
          #   secret_key=$($(aws iam list-access-keys --user-name ${each.key} --query "AccessKeyMetadata[0].SecretAccessKey" --output text) 2>/dev/null)
        else
          echo "No action required for user ${each.key}."
        fi
      else
        echo "No existing second access key found for user ${each.key}."
      fi
    EOF
  }
}
