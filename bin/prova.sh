#!/bin/bash

show_value () # array index
{
    local -n myarray=$1
    echo "${myarray[$2]}"
}

shadok=(1 2 3)
show_value shadok 1
