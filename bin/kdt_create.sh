#!/bin/bash

create(){
  KADOT_PATH=${BASH_SOURCE[0]%/*}/..
  # shellcheck source=/home/sandro0198/projects/bashProjects/Kadot/utils/bash_utils.sh
  source "$KADOT_PATH/utils/bash_utils.sh"

  # Check that the directory has a Kadot configuration file
  if [[ ! -f ".kadot" ]]; then
    echo "Kadot not found. Make sure to cd to the closest Kadot directory or create a new branch here"
    exit 1
  fi

  # I use the first argument as version name or I ask the user
  if [[ -z "$1" ]]; then
    echo "What will be the name of this version?"
    read -r version_name;
  else
    version_name=$1
  fi

  mapfile -t versions < <(jq -r '.versions[] .name' ".kadot")

  # Check if the version name already is in use
  if version_exists "$version_name" "${versions[@]}"; then
    echo "There exists a version with this name. Try with another one"
    exit
  fi

  # Ask if it inherites other versions, and check that they exist
  echo "Does it inherit other versions? [Y,n]"
  if get_confirm 0; then
    echo "Versions found: [${versions[*]}], \"q\" to quit "

    version_inherited=""
    while true; do
      read -r version_inherited
      if [[ "$version_inherited" == "q" ]]; then
        echo "No version inherited"
        break
      fi
      if version_exists "$version_inherited" "${versions[@]}"; then
        echo "Inheriting $version_inherited"
        break
      else
        echo "Version not found"
      fi
    done
  else
    echo "No version inherited"
  fi

  # Ask if it has a different target than the branch
  old_target=$(jq .target .kadot)
  target=""
  echo "Parent's target directory: $old_target"
  echo "Do you want to set another target directory? [y,N]"
  if get_confirm 1; then
    echo "Choose the new target"
    read -r target;
  fi

  # Check if the directory of the version exists and create it otherwise
  if [[ ! -d "$version_name" ]]; then
    mkdir "$version_name"
  fi

  # Update the .kadot file with the new version
  jq --arg version_name "$version_name" \
     --arg version_inherited "$version_inherited" \
     --arg target "$target" \
    '.versions += [{
       "name": $version_name,
       "target": $target,
       "inherits": $version_inherited,
       "divergents": [],
       "ignore": []
    }]' ".kadot" > .kadottmp

  mv .kadottmp .kadot
}
