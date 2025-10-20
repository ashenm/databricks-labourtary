locals {
  aws_iam_role_metastore_name = upper("${var.name_prefix}-metastore")
}

resource "aws_iam_role" "databricks" {
  name               = upper("${var.name_prefix}-databricks")
  assume_role_policy = data.databricks_aws_assume_role_policy.main.json
  tags               = { Name = upper("${var.name_prefix}-databricks") }
}

resource "aws_iam_role_policy" "databricks" {
  role   = aws_iam_role.databricks.name
  policy = data.databricks_aws_crossaccount_policy.main.json
}

resource "aws_iam_role" "metastore" {
  name               = local.aws_iam_role_metastore_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.main.json
}

resource "aws_iam_role_policy" "metastore" {
  role   = aws_iam_role.metastore.name
  policy = data.databricks_aws_unity_catalog_policy.main.json
}

resource "aws_iam_role" "fck-nat" {
  name               = upper("${var.name_prefix}-fck-nat")
  assume_role_policy = data.aws_iam_policy_document.ec2.json
  tags               = { Name = upper("${var.name_prefix}-fck-nat") }
}

resource "aws_iam_role_policy_attachment" "fck-nat" {
  role       = aws_iam_role.fck-nat.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMFullAccess"
}
