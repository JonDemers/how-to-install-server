#!/bin/bash

set -e

echo Disabling vim mouse integration which break copy-on-select
cat > ~/.vimrc <<EOF
source \$VIMRUNTIME/defaults.vim
set mouse-=a
EOF
