# AWS Secrets Role Type Check

## 1. Create a policy for EGP egp_iam_user_deny.sentinel

```hcl
import "strings"

# print(request.data)
credential_type = request.data.credential_type
print("CREDENTIAL_TYPE: ", credential_type)

allow_role_type = ["federation_token"]

role_type_check = rule {
  credential_type in allow_role_type
}

# Only check AWS Secret Engine
# Only check create, update
precond = rule {
	request.operation in ["create", "update"]
}

main = rule when precond {
    role_type_check
}
```

- precond : If the API request is POST, UPDATE
- role_type_check : Ensure the value of credential_type in the request's Body is an allowed type (e.g. allow federation_token)

## 2. Setting up sentinel policies in EGP

> EGP enforces the policy for the specified path

```bash
vault write /sys/policies/egp/iam_user_deny \
  policy=@egp_iam_user_deny.sentinel \
  enforcement_level=hard-mandatory \
  paths="aws/roles/*"
```

- Act when a request is made to the API path specified by paths

## 3. TEST

Path specified as EGP, rejected because credential_type is not an allowed type if iam_user

```bash
vault write aws/roles/iam-role \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOF
```

Output error messages

```log
Error writing data to aws/roles/iam-role: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/aws/roles/iam-role
Code: 403. Errors:

* 2 errors occurred:
	* egp standard policy "root/iam_user_deny" evaluation resulted in denial.

The specific error was:
<nil>

A trace of the execution for policy "root/iam_user_deny" is available:

Result: false

Description: <none>

print() output:

CREDENTIAL_TYPE:  iam_user


Rule "main" (root/iam_user_deny:19:1) = false
Rule "precond" (root/iam_user_deny:15:1) = true
Rule "role_type_check" (root/iam_user_deny:9:1) = false
	* permission denied
```

The federation_token is generated.

```bash
vault write aws/roles/sts-role \
    credential_type=federation_token \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOF
```

```log
Success! Data written to: aws/roles/sts-role
```