import json
from sys import stdin
from typing import TypedDict
from urllib.parse import urlparse
from databricks.sdk import AccountClient


class Workspace:
    id: int


class Result(TypedDict):
    workspaces: str # dict[str, Workspace]


class Query(TypedDict):
    workspace_url: list[str]


def get_query() -> Query:
    query: dict[str, str] = json.load(stdin)
    return {**query}


def get_workspaces(client: AccountClient) -> dict[str, Workspace]:
    return {ws.workspace_name: {"id": ws.workspace_id} for ws in client.workspaces.list()}


def get_workspace_name(workspace_url: str) -> str:
    [workspace_name, *_rest] = urlparse(url=workspace_url).hostname.split(".")
    return workspace_name


def main() -> Result:
    query: Query = get_query()
    client: AccountClient = AccountClient(host="https://accounts.cloud.databricks.com")
    workspaces: dict[str, Workspace] = get_workspaces(client=client)
    workspaces.pop(get_workspace_name(workspace_url=query["workspace_url"]), {})
    return {"workspaces": json.dumps(workspaces)}


if __name__ == "__main__":
    print(json.dumps(main()))
