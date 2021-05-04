#!/bin/sh
# NB: we're in sh

# pack everything into a single binary
cd src
fennel --compile --require-as-include umai.fnl > ../umai
cd ..

# add lua env header
echo "#!/usr/bin/env lua
$(cat umai)" > umai

# make file executable
chmod +x umai

# add to path
cp umai "$HOME/.garden/bin/umai"
