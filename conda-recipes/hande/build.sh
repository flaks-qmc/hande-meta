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

    # load Intel compilers
    set +x
    . /global/hds/software/cpu/eb3/icc/2018.1.163-GCC-6.4.0-2.28/compilers_and_libraries_2018.1.163/linux/bin/compilervars.sh intel64
    . /global/hds/software/cpu/eb3/ifort/2018.1.163-GCC-6.4.0-2.28/compilers_and_libraries_2018.1.163/linux/bin/compilervars.sh intel64
    . /global/hds/software/cpu/eb3/imkl/2018.1.163-iimpi-2018a/bin/compilervars.sh intel64
    set -x

    # link against conda MKL & GCC
    LAPACK_INTERJECT="${PREFIX}/lib/libmkl_rt.so"
    ALLOPTS="-gnu-prefix=${HOST}- ${OPTS}"

    # configure
    "${BUILD_PREFIX}"/bin/cmake \
        -H"${SRC_DIR}" \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_Fortran_COMPILER=ifort \
        -DCMAKE_C_COMPILER=icc \
        -DCMAKE_C_FLAGS="${ALLOPTS}" \
        -DCMAKE_Fortran_FLAGS="${ALLOPTS}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DPYMOD_INSTALL_LIBDIR="${PYMOD_INSTALL_LIBDIR}" \
        -DPYTHON_EXECUTABLE="${PYTHON}" \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DENABLE_OPENMP=ON \
        -DENABLE_XHOST=OFF \
        -DENABLE_GENERIC=OFF \
        -DLAPACK_LIBRARIES="${LAPACK_INTERJECT}" \
        -DBUILDNAME="LAB-RHEL7-gcc7.2-intel18.0.2-mkl-py${CONDA_PY}-release-conda" \
        -DSITE="gatech-conda" \
        -DSPHINX_ROOT="${PREFIX}"

    # build and install
    cmake --build build --target install -- -j"${CPU_COUNT}"

    # test
    ctest -M Nightly -T Test -T Submit -j"${CPU_COUNT}" -L quick
fi
