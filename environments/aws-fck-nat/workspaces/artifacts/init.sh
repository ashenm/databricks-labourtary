#!/usr/bin/env sh

set -x

echo 'ALL ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/baseline
chmod 440 /etc/sudoers.d/baseline
