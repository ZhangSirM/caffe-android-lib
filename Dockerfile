FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    build-essential \
    ca-certificates \
    curl \
    cmake \
    file \
    libtool \
    pkg-config \
    unzip \
    wget

RUN curl -SL \
    http://dl.google.com/android/repository/android-ndk-r11c-linux-x86_64.zip \
    -o /tmp/android-ndk.zip \
    && unzip -d /opt /tmp/android-ndk.zip \
    && rm -f /tmp/android-ndk.zip

COPY . /caffe-android-lib

ENV NDK_ROOT=/opt/android-ndk-r11c \
	N_JOBS=4 \
	ANDROID_ABI=arm64-v8a

WORKDIR /caffe-android-lib
