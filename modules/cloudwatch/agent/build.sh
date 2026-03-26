#!/bin/bash

set -ex

AWS_REGION="ap-southeast-1"
CLOUDWATCH_INSTALLER_BUILD_DIRECTORY="$(dirname $0)/artifacts"

mkdir --parent $CLOUDWATCH_INSTALLER_BUILD_DIRECTORY

wget --quiet --output-document="${CLOUDWATCH_INSTALLER_BUILD_DIRECTORY}/log4j12-json-layout-1.0.0.jar" \
  https://sa-iot.s3.ca-central-1.amazonaws.com/collateral/log4j12-json-layout-1.0.0.jar

# cloudwatch agent amd64
wget --quiet --output-document="${CLOUDWATCH_INSTALLER_BUILD_DIRECTORY}/amazon-cloudwatch-agent-x86_64.deb" \
  "https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/debian/amd64/latest/amazon-cloudwatch-agent.deb"
wget --quiet --output-document="${CLOUDWATCH_INSTALLER_BUILD_DIRECTORY}/amazon-cloudwatch-agent-x86_64.deb.sig" \
  "https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/debian/amd64/latest/amazon-cloudwatch-agent.deb.sig"

# cloudwatch agent arm64
wget --quiet --output-document="${CLOUDWATCH_INSTALLER_BUILD_DIRECTORY}/amazon-cloudwatch-agent-aarch64.deb" \
  "https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/debian/arm64/latest/amazon-cloudwatch-agent.deb"
wget --quiet --output-document="${CLOUDWATCH_INSTALLER_BUILD_DIRECTORY}/amazon-cloudwatch-agent-aarch64.deb.sig" \
  "https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/debian/arm64/latest/amazon-cloudwatch-agent.deb.sig"

# aws cli
wget --quiet --output-document="${CLOUDWATCH_INSTALLER_BUILD_DIRECTORY}/awscli-x86_64" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
wget --quiet --output-document="${CLOUDWATCH_INSTALLER_BUILD_DIRECTORY}/awscli-aarch64" "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
