import json
from databricks.sdk import AccountClient
from databricks.sdk.service.iam import ServicePrincipal
from typing import TypedDict
from os import environ


class Result(TypedDict):
    id: str
    display_name: str


def main() -> Result:
    account_client: AccountClient = AccountClient(host="https://accounts.cloud.databricks.com")
    application_id: str = environ["DATABRICKS_CLIENT_ID"]
    scim_filter_exp: str = f'applicationId eq "{application_id}"'
    service_principals: list[ServicePrincipal] = list(account_client.service_principals.list(filter=scim_filter_exp))

    if len(service_principals) != 1:
        raise ValueError("Found none or multiple service principals against application identifier")

    [service_principal] = service_principals
    return {"id": service_principal.id, "display_name": service_principal.display_name}


if __name__ == "__main__":
    print(json.dumps(main()))
