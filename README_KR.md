# AWS Secrets Role Type Check

> Vault의 Sentinel 형태는 다음을 참고하세요.
>
> [Vault - transit_exportable_deny](https://github.com/Great-Stone/policy-library-vault-aws-secret-type/blob/main/docs/policies/aws_secret_role_type_check.md)

## 1. Terraform Sample

[main.tf](https://github.com/Great-Stone/policy-library-vault-aws-secret-type/blob/main/policies/terraform/main.tf)

```hcl
resource "vault_aws_secret_backend_role" "role" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "deploy"
  credential_type = "iam_user"

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:*",
      "Resource": "*"
    }
  ]
}
EOT
}
```

- credential_type : 사용가능한 타입을 Sentinel에서 검증합니다.

## 2. Policy

```hcl
import "tfplan-functions" as plan

aws_secret_roles = plan.find_resources("vault_aws_secret_backend_role")

allow_role_type = ["federation_token"]

# (KR) AWS Secret Role 타입 지정에 오류가 있습니다.
# (EN) There was an error specifying the AWS Secret Role type.
credential_type_check = rule {
    all aws_secret_roles as _, rc {
      print("Allowed role type list is ", allow_role_type) and
      print("Current role type is ", rc.change.after.credential_type) and
      (rc.change.after.credential_type in allow_role_type)
    }
}

# Check aws role type
main = rule {
  credential_type_check
}
```

- credential_type_check : 모든 aws role 유형의 리소스의 `credential_type`의 값이 `allow_role_type`의 리스트에 있어야 합니다.

## 3. TEST

![](https://github.com/Great-Stone/policy-library-vault-aws-secret-type/blob/main/images/aws_secret_role_type_check.png?raw=true)