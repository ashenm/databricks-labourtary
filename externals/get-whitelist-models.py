import json
import re
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.catalog import RegisteredModelInfo
from typing import Match, Optional, Pattern, TypedDict
from sys import stdin

REGEXP_MODEL_NAME: Pattern = re.compile(r"^databricks-(?P<class>[a-zA-Z0-9]+)-[a-zA-Z0-9-]+$")
WHITELIST_MODEL_CLASSES: list[str] = ["claude", "gpt"]


class Query(TypedDict):
    host: str


class Result(TypedDict):
    models: str  # list[str]


def is_whitelist_model(model: RegisteredModelInfo) -> bool:
    match: Optional[Match] = REGEXP_MODEL_NAME.match(model.name)

    if not match:
        return False

    groups: dict[str, str] = match.groupdict()
    return groups["class"] in WHITELIST_MODEL_CLASSES


def get_whitelist_models(client: WorkspaceClient) -> list[str]:
    whitelist: list[str] = []
    models: list[RegisteredModelInfo] = list(client.registered_models.list(catalog_name="system", schema_name="ai"))

    for model in models:
        # allow only Databricks-hosted foundation models
        if not model.name.startswith("databricks-"):
            continue

        if not is_whitelist_model(model=model):
            continue

        whitelist.append(model.name)

    return whitelist


def get_query() -> Query:
    query: dict[str, str] = json.load(stdin)
    return {**query}


def main() -> Result:
    query: Query = get_query()
    client: WorkspaceClient = WorkspaceClient(host=query["host"])
    models: list[str] = get_whitelist_models(client=client)
    return {"models": json.dumps(models)}


if __name__ == "__main__":
    print(json.dumps(main()))
