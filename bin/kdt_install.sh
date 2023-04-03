#!/bin/bash

KADOT_PATH=${BASH_SOURCE[0]%/*}/..
# shellcheck source=/home/sandro0198/projects/bashProjects/kadot/utils/bash_utils.sh
source "$KADOT_PATH/utils/bash_utils.sh"

load_specific(){
  new_target=$(jq --arg name "$1" '.versions[] | select(.name == $name) | .target' .kadot)
  [[ "$new_target" == \"\" ]] || target=$new_target
  mapfile -t ignored_tmp < <(jq \
                            --arg name "$1" \
                            '.versions[] | select(.name == $name) | .ignore[]' .kadot)
  ignored=("${ignored[@]}" "${ignored_tmp[@]}")
}

load_kadot(){
  ignored=()
  mapfile -t ignored_tmp < <(jq .ignore[] .kadot)
  ignored=("${ignored[@]}" "${ignored_tmp[@]}")
  target=$(jq .target .kadot)
  return
}

launch_stow(){
  local -n to_ignore=$1
  target=${2//\"/}
  version_name=$3
  echo "" > "$version_name/.stow-local-ignore"
  local ignored_file
  for ignored_file in "${to_ignore[@]}"; do
    echo "${ignored_file//\"/}" >> "$version_name/.stow-local-ignore"
  done
  echo "Lancio"
  echo "stow -t $target $3"
  echo "Ignorando ${to_ignore[*]}"
  eval "stow -t $target $3"
  rm "$version_name/.stow-local-ignore"
  return
}

install(){
  if [[ ! -f ".kadot" ]]; then
    echo "Kadot not found. Make sure to cd to the closest Kadot directory"
    exit 1
  fi

  mapfile -t versions < <(jq -r '.versions[] .name' ".kadot")

  echo "Choose the version to install"
  echo "Versions found: [${versions[*]}], \"q\" to quit "

  version_to_install=""
  while true; do
    read -r version_to_install
    if [[ "$version_to_install" == "q" ]]; then
      echo "No version selected"
      exit 1
    fi
    if version_exists "$version_to_install" "${versions[@]}"; then
      echo "Installing $version_to_install"
      break
    else
      echo "Version not found"
    fi
  done

  load_kadot
  load_specific "$version_to_install"

  if [[ -f "$version_to_install/.kadot" ]]; then
    cd "$version_to_install" || exit
    install
  else
    launch_stow ignored "$target" "$version_to_install"
  fi
}
