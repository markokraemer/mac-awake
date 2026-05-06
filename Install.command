#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
./install.sh
echo
echo "Done. You can close this window."
read -r -p "Press enter to close..."

