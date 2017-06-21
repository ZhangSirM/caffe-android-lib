#!/usr/bin/env bash

set -eu

# shellcheck source=/dev/null
. "$(dirname "$0")/../config.sh"

SNAPPY_ROOT=${PROJECT_DIR}/snappy

if [ "${ANDROID_ABI}" = "armeabi-v7a-hard-softfp with NEON" ]; then
    TOOLCHAIN_DIR=$TOOLCHAIN_DIR/armeabi-v7a
elif [ "${ANDROID_ABI}" = "arm64-v8a"  ]; then
    TOOLCHAIN_DIR=$TOOLCHAIN_DIR/arm64-v8a
elif [ "${ANDROID_ABI}" = "armeabi"  ]; then
    TOOLCHAIN_DIR=$TOOLCHAIN_DIR/armeabi
elif [ "${ANDROID_ABI}" = "x86"  ]; then
    TOOLCHAIN_DIR=$TOOLCHAIN_DIR/x86
elif [ "${ANDROID_ABI}" = "x86_64"  ]; then
    TOOLCHAIN_DIR=$TOOLCHAIN_DIR/x86_64
else
    echo "Error: $0 is not supported for ABI: ${ANDROID_ABI}"
    exit 1
fi

if [ ! -d "$TOOLCHAIN_DIR" ]; then
    "$PROJECT_DIR/scripts/make-toolchain.sh"
fi

pushd "${SNAPPY_ROOT}"

export PATH=$TOOLCHAIN_DIR/bin:$PATH
export CC=$(find "$TOOLCHAIN_DIR/bin/" -name '*-gcc' -exec basename {} \;)
export CXX=$(find "$TOOLCHAIN_DIR/bin/" -name '*-g++' -exec basename {} \;)

if [ ! -f configure ]; then
    ./autogen.sh
fi

./configure --prefix="$INSTALL_DIR/snappy" --with-gflags=no --host="$(uname -m)"
make clean
make -j"${N_JOBS}"
rm -rf "${INSTALL_DIR}/snappy"
make install
git clean -fd 2> /dev/null || true

popd
