resource "databricks_cluster" "main" {
  cluster_name            = "Autoscaling"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 30
  data_security_mode      = "USER_ISOLATION"
  runtime_engine          = "STANDARD"

  autoscale {
    min_workers = 1
    max_workers = 1
  }

  spark_conf = {
    "spark.databricks.unityCatalogOnlyMode" : "True"
    "spark.databricks.sql.initial.catalog.namespace" : data.databricks_catalog.main.name
  }

  spark_env_vars = {
    AWS_MAX_RETRIES = "1"
  }
}

resource "databricks_sql_endpoint" "name" {
  name             = lower("${var.name_prefix}-default")
  cluster_size     = "X-Small"
  min_num_clusters = 1
  max_num_clusters = 1
  auto_stop_mins   = 15
  warehouse_type   = "PRO"
}

data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest" {
  long_term_support = true
}

data "databricks_catalog" "main" {
  name = "main"
}
