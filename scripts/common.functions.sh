#!/usr/bin/env bash -e
set -x

function die { local exitcode=$1; shift ; echo "ERROR:$ec: $@" ; exit $ec ; }
function isdir  { local dir="$1"; shift ;  [[ -d "$dir" ]] || return 43 ; }
function isfile { local file="$1"; shift ; [[ -f "$file" ]] || return 42 ; }
function ismounted { local mp="$1"; shift ; echo "checking_mount:$mnt"; mount|grep "$mp" || return 44 ; }






