#!/usr/bin/env bash

# Copied/adapted from https://github.com/conda-forge/hdf5-feedstock
# Note: --enable-unsupported is needed to have threadsafe together with C++ and Fortran

export LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix="${PREFIX}" \
            --with-pic \
            --with-zlib="${PREFIX}" \
            --with-pthread=yes  \
            --enable-cxx \
            --enable-fortran \
            --with-default-plugindir="${PREFIX}/lib/hdf5/plugin" \
            --enable-threadsafe \
            --enable-shared \
            --enable-build-mode=production \
            --enable-unsupported \
            --with-ssl

make -j "${CPU_COUNT}"
make check
make install

rm -rf "$PREFIX"/share/hdf5_examples
