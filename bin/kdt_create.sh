#!/bin/bash

version_exists(){
  for target in "${versions[@]}"; do
    if [[ "$1" == "$target" ]]; then
      return 0;
    fi
  done
  return 1;
}

# Check that the directory has a Kadot configuration file
if [[ ! -f ".kadot" ]]; then
  echo "Kadot not found. Make sure to cd to the closest Kadot directory"
  exit 1
fi

# I use the first argument as version name or I ask the user
if [[ -z "$1" ]]; then
  echo "What will be the name of this version?"
  read -r version_name;
else
  version_name=$1
fi

versions=($(jq -r '.versions[] .name' ".kadot"))

# Check if the version name already is in use
if version_exists "$version_name"; then
  echo "There exists a version with this name. Try with another one"
  exit
fi

# Ask if it inherites other versions, and check that they exist
echo "Does it inherit other versions?"
echo "Versions found: [${versions[*]}], \"n\" to quit "

version_inherited=""
while(true); do
  read -r version_inherited
  if [[ "$version_inherited" == "n" ]]; then
    echo "No version inherited"
    break
  fi
  if version_exists "$version_inherited"; then
    echo "Inheriting $version_inherited"
    break
  else
    echo "Version not found"
  fi
done

# Check if the directory of the version exists and create it otherwise
if [[ ! -d "$version_name" ]]; then
  mkdir "$version_name"
fi

# Update the .kadot file with the new version
jq --arg version_name "$version_name" \
   --arg version_inherited "$version_inherited" \
  '.versions += [{
     "name": $version_name,
     "inherits": $version_inherited,
     "divergents": [],
     "ignore": []
  }]' ".kadot" > .kadottmp

mv .kadottmp .kadot

