#!/usr/bin/env bash

# Copied/adapted from https://github.com/psi4/psi4meta

if [[ $(uname) == "Darwin" ]]; then

    # configure
    "${PREFIX}"/bin/cmake \
        -H"${SRC_DIR}" \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_Fortran_COMPILER="${PREFIX}"/bin/gfortran \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DPYMOD_INSTALL_LIBDIR="${PYMOD_INSTALL_LIBDIR}" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DBUILDNAME="RDR-OSX-clang7.3.0-accelerate-py${CONDA_PY}-release-conda" \
        -DSITE=gatech-mac-conda \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=''

        #-DLAPACK_LIBRARIES="/System/Library/Frameworks/Accelerate.framework/Accelerate" \
        #-DBLAS_LIBRARIES="/System/Library/Frameworks/Accelerate.framework/Accelerate"
        #-DENABLE_OPENMP=ON \

    # build and install
    cmake --build build --target install -- -j"${CPU_COUNT}"

    # test (full suite too stressful for macpsinet)
    ctest -M Nightly -T Test -T Submit -j"${CPU_COUNT}" -L quick

    # notes
    #sed -i.bak "s|/opt/anaconda1anaconda2anaconda3|${PREFIX}|g" ${PREFIX}/share/psi4/python/pcm_placeholder.py
    #DYLD_LIBRARY_PATH=${PREFIX}/lib:$DYLD_LIBRARY_PATH \
    #       PYTHONPATH=${PREFIX}/bin:${PREFIX}/lib/python2.7/site-packages:$PYTHONPATH \
    #             PATH=${PREFIX}/bin:$PATH \
fi

if [[ $(uname) == "Linux" ]]; then

    # link against conda MKL & GCC
    LAPACK_INTERJECT="${PREFIX}/lib/libmkl_rt.so"
    ALLOPTS="-gnu-prefix=${HOST}- ${OPTS}"

    echo $PREFIX
    echo $BUILD_PREFIX
    `type -P mpicc` --version
    `type -P mpifort` --version

    # configure
    "${BUILD_PREFIX}"/bin/cmake \
              -H"${SRC_DIR}" \
              -Bbuild \
              -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
              -DENABLE_HDF5=ON \
              -DENABLE_UUID=ON \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_Fortran_COMPILER=$(type -P mpifort) \
              -DCMAKE_C_COMPILER=$(type -P mpicc) \
              -DENABLE_MPI=ON \
              -DENABLE_SCALAPACK=ON \
              -DPYTHON_EXECUTABLE="${PYTHON}" \
              -DCMAKE_PREFIX_PATH="${PREFIX}" \
              -DENABLE_OPENMP=ON
              #-DTRLan_LIBRARIES="-L$DEPS/trlan/lib -ltrlan" \

    # build and install
    cmake --build build --target install -- -j"${CPU_COUNT}"

    # test
    ctest -M Nightly -T Test -T Submit -j"${CPU_COUNT}" -L quick
fi
