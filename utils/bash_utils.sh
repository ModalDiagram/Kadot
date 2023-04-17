#!/bin/bash

# This function asks user for confirmation.
# If the user input is empty the function returns the default $1, which
# must be 0 (yes) or 1 (no).
get_confirm(){
  while true; do
    read -r input;
    if [[ -z "$input" && -n "$1" ]]; then
      return "$1"
    fi
    case "$input" in
      y | Y ) return 0
        ;;
      n | N ) return 1
        ;;
    esac
    echo "Choice not found"
  done
}

# This function takes the version name to check as first input and the
# names of existing versions as successive inputs.
# It basically checks that $1 is not among $(n>1)
version_exists(){
  local my_version=$1
  shift
  for target in "$@"; do
    if [[ "$my_version" == "$target" ]]; then
      return 0;
    fi
  done
  return 1;
}
