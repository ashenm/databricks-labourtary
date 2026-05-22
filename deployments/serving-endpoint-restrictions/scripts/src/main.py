import sys
import logging
from argparse import ArgumentParser, Namespace
from os.path import normpath
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.serving import (
    AiGatewayRateLimit,
    AiGatewayRateLimitRenewalPeriod,
    AiGatewayRateLimitKey,
    ServingEndpoint,
)
from typing import TypedDict

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

#
# Setting PYTHONPATH isn't available on classic or serverless compute
# Hence, monkey-patching path to allow module resolution at runtime
# https://community.databricks.com/t5/data-engineering/set-pythonpath-when-executing-workflows/td-p/11835
#
__file__: str = dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()
__dirname__: str = __file__.removesuffix("/scripts/src/main.py")
sys.path.insert(0, normpath(f"/Workspace/{__dirname__}"))

from scripts.lib.client import get_workspace_client

WHITELIST_MODEL_CLASSES: list[str] = [
    "claude",
    "gemini",
    "gpt",
]

BLACKLIST_RATE_LIMITS: list[AiGatewayRateLimit] = [
    AiGatewayRateLimit(
        renewal_period=AiGatewayRateLimitRenewalPeriod.MINUTE,
        key=AiGatewayRateLimitKey.ENDPOINT,
        calls=0,
    ),
    AiGatewayRateLimit(
        renewal_period=AiGatewayRateLimitRenewalPeriod.MINUTE,
        key=AiGatewayRateLimitKey.ENDPOINT,
        tokens=0,
    ),
    AiGatewayRateLimit(
        renewal_period=AiGatewayRateLimitRenewalPeriod.MINUTE,
        key=AiGatewayRateLimitKey.USER,
        calls=0,
    ),
    AiGatewayRateLimit(
        renewal_period=AiGatewayRateLimitRenewalPeriod.MINUTE,
        key=AiGatewayRateLimitKey.USER,
        tokens=0,
    ),
]


class Config(TypedDict):
    rate_limits: dict[str, list[AiGatewayRateLimit]]


def is_whitelist_serving_endpoints(serving_endpoint: dict) -> bool:
    for served_entity in serving_endpoint["config"]["served_entities"]:
        if served_entity["foundation_model"]["model_class"] not in WHITELIST_MODEL_CLASSES:
            return False
    return True


def get_serving_endpoints(client: WorkspaceClient) -> list[dict]:
    #
    # SDK spec yet to include all attributes and therefore
    # using manual API request as opposed to client.serving_endpoints.list
    #
    response: dict = client.api_client.do("GET", "/api/2.0/serving-endpoints")
    return response["endpoints"]


def get_argument_parser() -> ArgumentParser:
    parser: ArgumentParser = ArgumentParser()
    parser.add_argument("--auxiliaries", required=False, action="append", dest="auxiliaries", default=[])
    return parser


def main() -> None:
    args: Namespace = get_argument_parser().parse_args()
    client: WorkspaceClient = get_workspace_client()

    WHITELIST_MODEL_CLASSES.extend(args.auxiliaries)

    serving_endpoints: list[ServingEndpoint] = get_serving_endpoints(client=client)

    for serving_endpoint in serving_endpoints:
        name: str = serving_endpoint["name"]
        if is_whitelist_serving_endpoints(serving_endpoint=serving_endpoint):
            print(f"Leaving serving endpoint {name} with default rate limits")
            continue
        print(f"Disabling serving endpoint {name} by applying blacklist rate limits")
        client.serving_endpoints.put_ai_gateway(name=name, rate_limits=BLACKLIST_RATE_LIMITS)


if __name__ == "__main__":
    main()
