#!/usr/bin/env bash

cd /src/delft3d/src
pwd
ls -alh
# TODO: try with the new cmake
./autogen.sh
export FFLAGS=-fallow-argument-mismatch
export FCFLAGS=-fallow-argument-mismatch
./configure --prefix=/usr/local
# now it will fail because it assumes this part to be built
pushd /src/delft3d/src/third_party_open/version_number/packages/version_number/src
make
popd
# go back and try again
./configure --prefix=/usr/local
# now we can build nefis
cd /src/delft3d/src/utils_lgpl/nefis
make
make install

cd /src/nefis-python
# build the nefis library
pip3 install -e .
# run the testbed
pytest-3

# mkdir build
# cd build
# ccmake ../cmake/
