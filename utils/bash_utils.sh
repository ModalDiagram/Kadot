#!/bin/bash

get_confirm(){
  while true; do
    read -r input;
    case "$input" in
      y | Y ) return 0
        ;;
      n | N ) return 1
        ;;
    esac
    echo "Choice not found"
  done
}

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
