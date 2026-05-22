#!/usr/bin/env sh

set -e

SCRIPTS_DIRECTORY=$(realpath $(dirname $0))
pip install --requirement ${SCRIPTS_DIRECTORY}/requirements.txt
