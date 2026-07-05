#!/usr/bin/env python3
import json
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.catalog import ArtifactAllowlistInfo, ArtifactMatcher, ArtifactType, MatchType
from typing import TypedDict
from sys import stdin


class Query(TypedDict):
    host: str
    paths: list[str]
    prefix: str
    type: ArtifactType


class Matcher(TypedDict):
    artifact: str
    match_type: str


class Result(TypedDict):
    matchers: str


def get_query() -> Query:
    query: dict[str, str] = json.load(stdin)
    return {**query, "paths": json.loads(query["paths"]), "type": ArtifactType[query["type"]]}


def get_current_allowlist_matchers(client: WorkspaceClient, artifact_type: ArtifactType) -> list[ArtifactMatcher]:
    result: ArtifactAllowlistInfo = client.artifact_allowlists.get(artifact_type=artifact_type)
    return result.artifact_matchers


def union(prefix: str, current: list[ArtifactMatcher], paths: list[str]) -> dict[str, Matcher]:
    result: dict[str, Matcher] = {}
    selection: str = prefix.casefold()

    for path in paths:
        [_prefix, catalog, schema, volume, *_rest] = path.split("/")
        result[f"{catalog}_{schema}_{volume}"] = {"artifact": path, "match_type": MatchType.PREFIX_MATCH.value}

    for matcher in current:
        if matcher.artifact.casefold().startswith(selection):
            continue

        [_prefix, catalog, schema, volume, *_rest] = matcher.artifact.split("/")
        result[f"{catalog}_{schema}_{volume}"] = {"artifact": matcher.artifact, "match_type": matcher.match_type.value}

    return result


def main() -> Result:
    query: Query = get_query()
    client: WorkspaceClient = WorkspaceClient(host=query["host"])
    current: list[ArtifactMatcher] = get_current_allowlist_matchers(client=client, artifact_type=query["type"])
    matchers: dict[str, Matcher] = union(prefix=query["prefix"], current=current, paths=query["paths"])
    return {"matchers": json.dumps(matchers)}


if __name__ == "__main__":
    print(json.dumps(main()), end="")
