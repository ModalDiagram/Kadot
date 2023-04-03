#!/bin/bash

branch(){
  KADOT_PATH=${BASH_SOURCE[0]%/*}/..
  # shellcheck source=/home/sandro0198/projects/bashProjects/kadot/utils/bash_utils.sh
  source "$KADOT_PATH/utils/bash_utils.sh"

  echo "I am creating a new Kadot at $(pwd)"

  if [[ -f "../.kadot" ]]; then
    echo "Found a parent Kadot directory"
    echo "Do you want to inherit its target and info? [Y/n]"
    if get_confirm; then
      IFS=$'\n' read -r -d '' target info < <(jq -r '.target, .info' "../.kadot")
    fi
  fi

  if [[ -z "$target" ]]; then
    echo "Choose your target folder: "
    read -r target;
    echo "Do you have additional info: "
    read -r info;
  fi

  jq --null-input \
    --arg target "$target" \
    --arg info "$info" \
    '{"target": $target, "info": $info, "ignore": [], "versions": []}' > .kadot
}
