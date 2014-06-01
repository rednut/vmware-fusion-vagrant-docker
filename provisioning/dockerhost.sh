#!/bin/bash -ex


TS_START=$(date +%s)
SCRIPT_NAME=$(basename "$0")
PROVISION="dockerhost"
DESCRIPTION="Docker Host Daemon"

echo "Provisioning $DESCRIPTION using $SCRIPT_NAME"
echo "Start timestamp: $TS_START)"
touch /var/run/provision.$PROVISION.started
touch /var/run/provision.$PROVISION.finished




exit 0

