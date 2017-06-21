#!/usr/bin/env bash

set -eu

# shellcheck source=/dev/null
. "$(dirname "$0")/../config.sh"

OPENBLAS_ROOT=${PROJECT_DIR}/OpenBLAS

case "$(uname -s)" in
    Darwin)
    OS=darwin
    ;;
    Linux)
    OS=linux
    ;;
    CYGWIN*|MINGW*|MSYS*)
    OS=windows
    ;;
    *)
    echo "Unknown OS"
    exit 1
    ;;
esac

if [ "$(uname -m)" = "x86_64"  ]; then
    BIT=x86_64
else
    BIT=x86
fi

if [ "${ANDROID_ABI}" = "armeabi-v7a-hard-softfp with NEON" ]; then
    CROSS_SUFFIX=$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}-${BIT}/bin/arm-linux-androideabi-
    SYSROOT=$NDK_ROOT/platforms/android-21/arch-arm
    NO_LAPACK=${NO_LAPACK:-1}
    TARGET=ARMV7
    BINARY=32
elif [ "${ANDROID_ABI}" = "arm64-v8a"  ]; then
    CROSS_SUFFIX=$NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/${OS}-${BIT}/bin/aarch64-linux-android-
    SYSROOT=$NDK_ROOT/platforms/android-21/arch-arm64
    NO_LAPACK=${NO_LAPACK:-1}
    TARGET=ARMV8
    BINARY=64
elif [ "${ANDROID_ABI}" = "armeabi"  ]; then
    CROSS_SUFFIX=$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}-${BIT}/bin/arm-linux-androideabi-
    SYSROOT=$NDK_ROOT/platforms/android-21/arch-arm
    NO_LAPACK=1
    TARGET=ARMV5
    BINARY=32
elif [ "${ANDROID_ABI}" = "x86"  ]; then
    CROSS_SUFFIX=$NDK_ROOT/toolchains/x86-4.9/prebuilt/${OS}-${BIT}/bin/i686-linux-android-
    SYSROOT=$NDK_ROOT/platforms/android-21/arch-x86
    NO_LAPACK=1
    TARGET=ATOM
    BINARY=32
elif [ "${ANDROID_ABI}" = "x86_64"  ]; then
    CROSS_SUFFIX=$NDK_ROOT/toolchains/x86_64-4.9/prebuilt/${OS}-${BIT}/bin/x86_64-linux-android-
    SYSROOT=$NDK_ROOT/platforms/android-21/arch-x86_64
    NO_LAPACK=1
    TARGET=ATOM
    BINARY=64
else
    echo "Error: $0 is not supported for ABI: ${ANDROID_ABI}"
    exit 1
fi

pushd "${OPENBLAS_ROOT}"

make clean
make -j"${N_JOBS}" \
     CC="${CROSS_SUFFIX}gcc --sysroot=$SYSROOT" \
     FC="${CROSS_SUFFIX}gfortran --sysroot=$SYSROOT" \
     CROSS_SUFFIX="$CROSS_SUFFIX" \
     HOSTCC=gcc USE_THREAD=1 NUM_THREADS=8 USE_OPENMP=1 \
     NO_LAPACK=$NO_LAPACK TARGET=$TARGET BINARY=$BINARY

rm -rf "$INSTALL_DIR/openblas"
make PREFIX="$INSTALL_DIR/openblas" install

popd
