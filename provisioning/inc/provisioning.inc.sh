#!/bin/bash -ex

STATE_FILES_PATH=/var/run/
TS_started=$(NOW)
TS_finished=$TS_started


function NOW {
  $(date +%s)
}

function DURATION {
  local T1=$1 ; shift ;
  local T2=$2 ; shift ;
  [[ "$T1" -gt "$T2" ]] \
    && echo $(expr $T2 - $T1) \
    || echo $(expr $T1 - $T2)
}

function touch_state_file {
  local name=$1; shift ;
  local state=$1; shift ;
  local msg=$1; shift ;


  local ts=$(NOW)

  TS_$state=$ts

  echo "DEBUG: ts=$ts, path=$path, name=$name, state=$state, msg=$msg"
  fn="$STATE_FILES_PATH/provision.$name.$state"
  touch $fn;
  [[ "x$msg" != "x" ]] && \
    echo "$msg" > "$fn"
}

function get_state_file_timestamp {
  local file="$1"; shift ;
  
}

function touch_start {
  local name="$1" ; shift ;
  local msg="$1" ; shift ;
  touch_state_file "$name" "started" "$msg"
}

function touch_finished {
  local name="$1" ; shift ;
  local msg="$1" ; shift ;
  
  touch_state_file "$name" "finished" "$msg" 
}


TS_START=$(NOW)
SCRIPT_NAME=$(basename "$0")
PROVISION="provison-include"
DESCRIPTION="provisioner include file"

echo "Provisioning $DESCRIPTION using $SCRIPT_NAME"
echo "Start timestamp: $TS_START)"
touch /var/run/provision.$PROVISION.started
touch /var/run/provision.$PROVISION.finished




exit 0

