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