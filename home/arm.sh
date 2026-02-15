#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# set -x # uncomment to debug, beware of secrets!

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"

cp -rv "${SCRIPT_DIR}/configs/" "${HOME}/"
cp -rv "${SCRIPT_DIR}/scripts/" "${HOME}/"

echo "Home directory updated."