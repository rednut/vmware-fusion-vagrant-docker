#!/bin/bash

if [[ $# -lt 3 ]]; then
  echo "--=[ write network interface ip addresses to state directory ]=--"
  echo "usage:"
  echo "      $0 <base_state_dir> ifname1 ... ifnameN"
  exit 1
fi


source ./netif.functions.sh

VERBOSE=1
STATE_DIR=/vagrant/state
INTERFACES="$@"

if-addr-writer \
        "$STATE_DIR" \
        $INTERFACES
