#!/bin/bash

KADOT_PATH=${BASH_SOURCE[0]%/*}/..
# shellcheck source=/home/sandro0198/projects/bashProjects/Kadot/utils/bash_utils.sh
source "$KADOT_PATH/utils/bash_utils.sh"

# This function loads the fields associated with a specific version (given as $1), that is
# the specific target (if it exists) and the specific ignored files.
load_specific(){
  new_target=$(jq --arg name "$1" '.versions[] | select(.name == $name) | .target' .kadot)
  [[ "$new_target" == \"\" ]] || target=$new_target
  mapfile -t ignored_tmp < <(jq \
                            --arg name "$1" \
                            '.versions[] | select(.name == $name) | .ignore[]' .kadot)
  ignored=("${ignored[@]}" "${ignored_tmp[@]}")
}

# This function loads the fields associated with the whole branch, that is
# the globally ignored files and the global target
load_kadot(){
  ignored=()
  mapfile -t ignored_tmp < <(jq .ignore[] .kadot)
  ignored=("${ignored[@]}" "${ignored_tmp[@]}")
  target=$(jq .target .kadot)
  return
}

# This function effectively launches GNU Stow. It takes in input:
# - $1 the array of files to ignore
# - $2 the target (global or specific)
# - $3 the name of the version to install
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
  # Check that the directory exists and if not create it.
  # Stow will fail if directory doesn't exist.
  expanded_target="$(eval echo "$target")"
  if [[ ! -d "$expanded_target" ]]; then
    echo "WARNING: target directory $target doesn't exists. Do you want me to create it (or quit)? [Y,n]"
    if get_confirm 0; then
      echo "I am creating the directory and installing the version"
      mkdir "$expanded_target"
    else
      echo "Directory not created, quitting"
      exit 1
    fi
  fi
  stow -t "$expanded_target" "$3"
  rm "$version_name/.stow-local-ignore"
  return
}

# This is the main function. Takes as only input the name of the version to install
# (but it is not necessary).
# Then it loads the global and specific fields of .kadot and eventually launches stow
install(){
  if [[ ! -f ".kadot" ]]; then
    echo "Kadot not found. Make sure to cd to the closest Kadot directory"
    exit 1
  fi

  mapfile -t versions < <(jq -r '.versions[] .name' ".kadot")

  if [[ -n "$1" ]]; then
    version_to_install=$1
    if version_exists "$version_to_install" "${versions[@]}"; then
      echo "Installing $1"
    else
      echo "Version $version_to_install not found"
      exit 1
    fi
  else
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
  fi

  load_kadot
  load_specific "$version_to_install"

  if [[ -f "$version_to_install/.kadot" ]]; then
    cd "$version_to_install" || exit
    install
  else
    launch_stow ignored "$target" "$version_to_install"
  fi
}
