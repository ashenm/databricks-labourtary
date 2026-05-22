locals {
  scripts = fileset(path.module, "/scripts/**")
}

provider "databricks" {
  host = "https://fe-sandbox-starscream.cloud.databricks.com"
}

resource "databricks_job" "main" {
  name      = "(Automation) Model Serving Endpoints"
  edit_mode = "UI_LOCKED"

  job_cluster {
    job_cluster_key = "main"

    new_cluster {
      num_workers   = 0
      kind          = "CLASSIC_PREVIEW"
      spark_version = data.databricks_spark_version.latest.id

      spark_env_vars = {
        "PYTHONPATH" = databricks_directory.automations.path
      }

      data_security_mode = "SINGLE_USER"
      node_type_id       = data.databricks_node_type.smallest.id
    }
  }

  task {
    task_key        = "update-rate-limits"
    job_cluster_key = "main"

    spark_python_task {
      source      = "WORKSPACE"
      python_file = databricks_workspace_file.scripts["scripts/src/main.py"].path
      parameters  = []
    }

    max_retries               = 3
    min_retry_interval_millis = 10000
    retry_on_timeout          = true
    timeout_seconds           = 3600
  }

  queue {
    enabled = true
  }
}

data "databricks_spark_version" "latest" {
  long_term_support = true
}

data "databricks_node_type" "smallest" {
  local_disk = true
}
