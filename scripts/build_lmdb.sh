#!/usr/bin/env sh

set -e

if [ -z "$NDK_ROOT" ] && [ "$#" -eq 0 ]; then
    echo "Either \$NDK_ROOT should be set or provided as argument"
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    echo "      '${0} /path/to/ndk'"
    exit 1
else
    NDK_ROOT="${1:-${NDK_ROOT}}"
fi

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

WD=$(readlink -f "$(dirname "$0")/..")
LMDB_ROOT=${WD}/lmdb/libraries/liblmdb
INSTALL_DIR=${WD}/android_lib
N_JOBS=${N_JOBS:-4}

cd "${LMDB_ROOT}"

case "$ANDROID_ABI" in
    armeabi*)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/arm-linux-androideabi-gcc --sysroot=$NDK_ROOT/platforms/android-21/arch-arm"
        AR=$TOOLCHAIN_DIR/arm-linux-androideabi-ar
        ;;
    arm64-v8a)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/aarch64-linux-android-gcc --sysroot=$NDK_ROOT/platforms/android-21/arch-arm64"
        AR=$TOOLCHAIN_DIR/aarch64-linux-android-ar
        ;;
    x86)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/x86-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/i686-linux-android-gcc --sysroot=$NDK_ROOT/platforms/android-21/arch-x86"
        AR=$TOOLCHAIN_DIR/i686-linux-android-ar
        ;;
    x86_64)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/x86_64-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/x86_64-linux-android-gcc --sysroot=$NDK_ROOT/platforms/android-21/arch-x86_64"
        AR=$TOOLCHAIN_DIR/x86_64-linux-android-ar
        ;;
    *)
        echo "Error: not support LMDB for ABI: ${ANDROID_ABI}"
        exit 1
        ;;
esac

make clean
make -j"${N_JOBS}" CC="${CC}" AR="${AR}" XCFLAGS="-DMDB_DSYNC=O_SYNC -DMDB_USE_ROBUST=0"

rm -rf "$INSTALL_DIR/lmdb"
make prefix="$INSTALL_DIR/lmdb" install

cd "${WD}"
