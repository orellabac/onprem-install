#!/bin/bash

# echo "Option 1: $1"
# echo "Option 2: $2"

mongoJsScript={{SCRIPT_NAME}}.js
cp $mongoJsScript ~/.codestream
cd ~/.codestream
./single-host-preview-install.sh --repair-db $mongoJsScript
/bin/rm -f ~/.codestream/$mongoJsScript

exit 0
