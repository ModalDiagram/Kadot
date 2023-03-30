#!/bin/bash

echo "I am creating a new Kadot at $(pwd)"
echo "Choose your target folder: "
read -r target;
echo "Do you have additional info: "
read -r info;

jq --null-input \
  --arg target "$target" \
  --arg info "$info" \
  '{"target": $target, "info": $info, "ignore": [], "versions": []}' > .kadot
