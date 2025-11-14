locals {
  unity_catalog_role_name = upper("${var.name_prefix}-unity-catalog")
  unity_catalog_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.unity_catalog_role_name}"
}

resource "aws_iam_role" "unity_catalog" {
  name               = local.unity_catalog_role_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.main.json
}

resource "aws_iam_role_policy" "unity_catalog" {
  role   = aws_iam_role.unity_catalog.name
  policy = data.databricks_aws_unity_catalog_policy.main.json
}
