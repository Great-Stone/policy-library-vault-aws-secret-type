module "tfplan-functions" {
  source = "./modules/tfplan-functions.sentinel"
}

policy "aws_secret_role_type_check" {
  source = "./policies/aws_secret_role_type_check.sentinel"
  enforcement_level = "soft-mandatory"
}