#!/bin/sh
# NB: we're in sh

# pack everything into a single binary,
cd src
fennel --compile --require-as-include blossom.fnl > ../blossom

# add lua env header
echo "#!/usr/bin/env lua
$(cat ../blossom)" > ../blossom

# make file executable
chmod +x ../blossom
