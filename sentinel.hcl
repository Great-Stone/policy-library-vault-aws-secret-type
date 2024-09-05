# Vault Sentinel - EGP

policy "egp_iam_user_deny" {
  source = "./policies/egp_iam_user_deny.sentinel"
  enforcement_level = "soft-mandatory"
}