from databricks.sdk import WorkspaceClient


def get_workspace_client() -> WorkspaceClient:
    return WorkspaceClient(host="https://fe-sandbox-starscream.cloud.databricks.com/")
