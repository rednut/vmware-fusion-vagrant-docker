#!/bib/bash

function die { echo "ERROR: $1"; exit 1; }

function int-ip { /sbin/ifconfig $1 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'; }




function if-addr-writer {

  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <base_dir> [interface1] [interfaceN] "
  fi


  local BASE_DIR=$1; shift
  [ -d "$BASE_DIR" ] || mkdir -p "$BASE_DIR" || \
	die "cannot create MISSING BASE_DIR: $BASE_DIR"

  local INTERFACES="$@"
  [[ "x$INTERFACES" == "x" ]] && \
	die "you must supply some interfaces"

  #local STATE_BASE_DIR="$BASE_DIR/"
  #mkdir -p "$STATE_BASE_DIR" || \
  #	die "cannot create STATE_BASE_DIR=$STATE_BASE_DIR"

  local IF_FILE="$BASE_DIR/interfaces"

  if [[ "$VERBOSE" -gt 0 ]]; then
    echo "HOSTNAME:          $HOSTNAME"
    echo "STATE_BASE_DIR:    $BASE_DIR"
    echo "INTERFACES_FILE:   $IF_FILE"
    echo "INTERFACES:        $INTERFACES"
   fi

  # remove old interfaces file
  [[ -f "$IF_FILE" ]] && rm "$IF_FILE"
  touch "$IF_FILE" || \
	die "cannot create $IF_FILE"


  for interface in $INTERFACES; do
        
        # file to store address of interface
  	local IF_ADDR_FILE="$BASE_DIR/$interface"
        touch $IF_ADDR_FILE;


        # ip of interafce
	local address=$(int-ip $interface)
        
	# store if in the interfaces file
        echo "$address" > $IF_ADDR_FILE;

        # add interface to list file
	echo "$interface" >> $IF_FILE
   	
	
	echo "$interface=$address"

    #	echo "$IF_ADDR_FILE: $interface=$address"
  done

}

