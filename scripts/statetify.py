#!/usr/bin/env python3
#
# Update state file to match automation cleanup
# and prepare all leftover resources for a forceful destroy
#
#

import json
import boto3
from boto3 import Session
from shutil import copyfile
from argparse import ArgumentParser, Namespace


DATABRICKS_AUTOMATION_CLEANUP_EXCEPTIONS: list[str] = ["databricks_metastore", "databricks_mws_credentials"]


def is_databricks_resource(resource: dict) -> bool:
    return resource["type"].startswith("databricks_")


def is_aws_route53_zone(resource: dict) -> bool:
    return resource["type"] == "aws_route53_zone"


def is_aws_s3_bucket(resource: dict) -> bool:
    return resource["type"] == "aws_s3_bucket"


def is_leftover_databricks_resource(resource: dict) -> bool:
    resource_type: str = resource["type"]
    return resource_type.startswith("databricks_") and resource_type not in DATABRICKS_AUTOMATION_CLEANUP_EXCEPTIONS


def is_leftover_resource(resource: dict) -> bool:
    return not is_leftover_databricks_resource(resource=resource) and not is_aws_route53_zone(resource=resource)


def main(filepath: str) -> None:
    state: dict

    copyfile(src=filepath, dst=f"{filepath}.backup")

    with open(file=filepath, mode="r") as stream:
        state = json.load(fp=stream)

    retains: list[dict] = [resource for resource in state["resources"] if is_leftover_resource(resource=resource)]
    removals: int = len(state["resources"]) - len(retains)

    print(f"Sanitizing state file {filepath} removing {removals}(s) resource entries")

    with open(file=filepath, mode="w") as stream:
        stream.write(json.dumps({**state, "resources": retains}))

    try:
        clean_storage_contents(resources=[resource for resource in retains if is_aws_s3_bucket(resource=resource)])
    except boto3.client("s3").exceptions.NoSuchBucket:
        pass


def clean_storage_contents(resources: list[dict]) -> None:
    print(f"Cleaning up contents of {len(resources)} storage roots(s)")
    s3: Session = boto3.resource("s3")
    for resource in resources:
        for instance in resource["instances"]:
            s3.Bucket(instance["attributes"]["bucket"]).objects.all().delete()


def get_arguments_parser() -> ArgumentParser:
    parser: ArgumentParser = ArgumentParser()
    parser.add_argument("FILEPATH", action="store")
    return parser


if __name__ == "__main__":
    args: Namespace = get_arguments_parser().parse_args()
    main(filepath=args.FILEPATH)
