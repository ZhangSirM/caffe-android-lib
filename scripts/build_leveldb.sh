#!/usr/bin/env bash

set -eu

# shellcheck source=/dev/null
. "$(dirname "$0")/../config.sh"

LEVELDB_ROOT=${PROJECT_DIR}/leveldb

"$PROJECT_DIR/scripts/make-toolchain.sh"

export PATH=$TOOLCHAIN_DIR/bin:$PATH
export CC=$(find "$TOOLCHAIN_DIR/bin/" -name '*-gcc' -exec basename {} \;)
export CXX=$(find "$TOOLCHAIN_DIR/bin/" -name '*-g++' -exec basename {} \;)
export TARGET_OS=OS_ANDROID_CROSSCOMPILE

pushd "${LEVELDB_ROOT}"

make clean
make -j"${N_JOBS}" out-static/libleveldb.a
rm -rf "${INSTALL_DIR}/leveldb"
mkdir -p "${INSTALL_DIR}/leveldb/lib"
cp -r include/ "${INSTALL_DIR}/leveldb"
cp out-static/libleveldb.a "${INSTALL_DIR}/leveldb/lib"

popd
