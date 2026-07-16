#!/usr/bin/env python3
import json
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.sql import (
    WarehousePermissions,
    WarehouseAccessControlRequest,
    WarehouseAccessControlResponse,
    WarehousePermission,
)
from typing import TypedDict
from sys import stdin


class Query(TypedDict):
    host: str
    sql_warehouse_id: str
    permissions: str  # list[WarehouseAccessControlRequest]


class Matcher(TypedDict):
    artifact: str
    match_type: str


class Result(TypedDict):
    acls: str  # list[WarehouseAccessControlRequest]


def get_query() -> Query:
    query: dict[str, str] = json.load(stdin)
    permissions: list[WarehouseAccessControlResponse] = []
    for permission in json.loads(query.get("permissions", "[]")):
        permissions.append(marshall(acl=WarehouseAccessControlRequest.from_dict(permission)))
    return {**query, "permissions": permissions}


def get_current_permissions(client: WorkspaceClient, warehouse_id: str) -> list[WarehouseAccessControlResponse]:
    warehouse_permissions: WarehousePermissions = client.warehouses.get_permissions(warehouse_id=warehouse_id)
    for acl in warehouse_permissions.access_control_list:
        acl.all_permissions = [permission for permission in acl.all_permissions if not permission.inherited]
    return list(filter(lambda acl: acl.all_permissions, warehouse_permissions.access_control_list))


def rehash(acls: list[WarehouseAccessControlResponse]) -> dict[str, WarehouseAccessControlResponse]:
    return {next(filter(bool, [acl.group_name, acl.service_principal_name, acl.user_name])): acl for acl in acls}


def union(current: list[WarehouseAccessControlResponse], config: list[WarehouseAccessControlResponse]) -> list[WarehouseAccessControlResponse]:
    return (rehash(acls=current) | rehash(acls=config)).values()


def marshall(acl: WarehouseAccessControlRequest) -> WarehouseAccessControlResponse:
    permissions: list[WarehousePermission] = [WarehousePermission(permission_level=acl.permission_level).as_dict()]
    return WarehouseAccessControlResponse.from_dict({**acl.as_dict(), "all_permissions": permissions})


def unmarshall(acl: WarehouseAccessControlResponse) -> WarehouseAccessControlRequest:
    [permission] = acl.all_permissions
    return WarehouseAccessControlRequest.from_dict({**acl.as_dict(), "permission_level": permission.permission_level.value})


def main() -> Result:
    query: Query = get_query()
    client: WorkspaceClient = WorkspaceClient(host=query["host"])
    current: list[WarehouseAccessControlResponse] = get_current_permissions(client=client, warehouse_id=query["sql_warehouse_id"])
    acls: list[WarehouseAccessControlResponse] = union(current=current, config=query["permissions"])
    return {"acls": json.dumps([unmarshall(acl=acl).as_dict() for acl in acls])}


if __name__ == "__main__":
    print(json.dumps(main()), end="")
