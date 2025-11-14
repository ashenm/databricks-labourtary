resource "databricks_cluster" "main" {
  cluster_name            = "Autoscaling"
  spark_version           = "17.3.x-scala2.13"
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 120
  data_security_mode      = "USER_ISOLATION"
  runtime_engine          = "STANDARD"

  autoscale {
    min_workers = 1
    max_workers = 1
  }

  aws_attributes {
    availability = "ON_DEMAND"
  }

  spark_conf = {
    "spark.databricks.unityCatalogOnlyMode" : "True"
    "spark.databricks.sql.initial.catalog.namespace" : databricks_catalog.main.name
  }

  spark_env_vars = {
    AWS_MAX_RETRIES = "1"
  }
}

# resource "databricks_sql_endpoint" "main" {
#   name             = "Default"
#   cluster_size     = "X-Small"
#   min_num_clusters = 1
#   max_num_clusters = 1
#   auto_stop_mins   = 15
#   warehouse_type   = "PRO"
# }

data "aws_caller_identity" "current" {}

data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest" {
  long_term_support = true
}
