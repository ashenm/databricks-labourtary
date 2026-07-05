locals {
  drivers = { for driver in setintersection(fileset("${path.module}/drivers", "**"), var.drivers) : driver => {
    source = driver
    type   = dirname(driver)
  } }

  base_policy_overrides = {
    node_type_id = {
      type         = "allowlist"
      values       = ["r7gd.large", "r7gd.xlarge", "r7gd.2xlarge", "r7gd.4xlarge"]
      defaultValue = "r7gd.large"
      isOptional   = true
    }
    num_workers = {
      type         = "range"
      defaultValue = 2
      minValue     = 0
      maxValue     = 4
      isOptional   = true
    }
    "docker_image.url" = {
      type   = "forbidden"
      hidden = true
    }
  }
  create_team_policies  = contains(var.cluster_policies, "team")
  __count_team_policies = local.create_team_policies ? 1 : 0
  create_user_policies  = contains(var.cluster_policies, "user")
  __count_user_policies = local.create_user_policies ? 1 : 0
}

resource "databricks_cluster_policy" "job_compute_team" {
  count            = local.__count_team_policies
  name             = "Job Compute - Team"
  policy_family_id = "job-cluster"
  policy_family_definition_overrides = jsonencode(merge(local.base_policy_overrides, {
    "custom_tags.Provisioner" = {
      type   = "fixed"
      value  = "Team"
      hidden = true
    }
  }))
}

resource "databricks_cluster_policy" "job_compute_user" {
  count            = local.__count_user_policies
  name             = "Job Compute - User"
  policy_family_id = "job-cluster"
  policy_family_definition_overrides = jsonencode(merge(local.base_policy_overrides, {
    "custom_tags.Provisioner" = {
      type   = "fixed"
      value  = "User"
      hidden = true
    }
  }))
  max_clusters_per_user = 1
}
