#!/usr/bin/env bash

set -eu

# shellcheck source=/dev/null
. "$(dirname "$0")/../config.sh"

mkdir -p "$TOOLCHAIN_DIR"

if [ "${ANDROID_ABI}" = "armeabi-v7a-hard-softfp with NEON" ]; then
    TOOLCHAIN=arm-linux-androideabi-4.9
    ABI=armeabi-v7a
elif [ "${ANDROID_ABI}" = "arm64-v8a"  ]; then
    TOOLCHAIN=aarch64-linux-android-4.9
    ABI=arm64-v8a
elif [ "${ANDROID_ABI}" = "armeabi"  ]; then
    TOOLCHAIN=arm-linux-androideabi-4.9
    ABI=armeabi
elif [ "${ANDROID_ABI}" = "x86"  ]; then
    TOOLCHAIN=x86-4.9
    ABI=x86
elif [ "${ANDROID_ABI}" = "x86_64"  ]; then
    TOOLCHAIN=x86_64-4.9
    ABI=x86_64
else
    echo "Error: $0 is not supported for ABI: ${ANDROID_ABI}"
    exit 1
fi

"$NDK_ROOT/build/tools/make-standalone-toolchain.sh" --install-dir="$TOOLCHAIN_DIR/$ABI" --platform=android-21 --toolchain=$TOOLCHAIN
