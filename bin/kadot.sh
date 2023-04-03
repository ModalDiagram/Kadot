#!/bin/bash

KADOT_PATH=${BASH_SOURCE[0]%/*}/..
# shellcheck source=/home/sandro0198/projects/bashProjects/kadot/utils/bash_utils.sh
source "$KADOT_PATH/utils/bash_utils.sh"
# shellcheck source=/home/sandro0198/projects/bashProjects/kadot/bin/kdt_branch.sh
source "$KADOT_PATH/bin/kdt_branch.sh"
# shellcheck source=/home/sandro0198/projects/bashProjects/kadot/bin/kdt_create.sh
source "$KADOT_PATH/bin/kdt_create.sh"
# shellcheck source=/home/sandro0198/projects/bashProjects/kadot/bin/kdt_install.sh
source "$KADOT_PATH/bin/kdt_install.sh"

case $1 in
  install ) install
    ;;
  create ) create
    ;;
  branch ) branch
    ;;
  * ) echo "I didn't understand the command"
esac
