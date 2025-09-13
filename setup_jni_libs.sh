#! /usr/bin/env bash
set -ex

NDK="$(flutter doctor --verbose 2>/dev/null \
    | rg 'Android SDK at' \
    | awk '{print $NF}')ndk/27.0.12077973"
if [ ! -d $NDK ];
then
    echo "Missing android ndk 27.0.12077973"
    exit 1
fi

echo "This step assumes Linux..."
PREFIX="$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"
CXXSO="libc++_shared.so"

TARGET_V7A="$PREFIX/arm-linux-androideabi/$CXXSO"
TARGET_V8A="$PREFIX/aarch64-linux-android/$CXXSO"
TARGET_X86="$PREFIX/x86_64-linux-android/$CXXSO"

V7A="android/app/src/main/jniLibs/armeabi-v7a/"
V8A="android/app/src/main/jniLibs/arm64-v8a/"
X86="android/app/src/main/jniLibs/x86_64/"

mkdir -p $V7A
mkdir -p $V8A
mkdir -p $X86
cp $TARGET_V7A $V7A
cp $TARGET_V8A $V8A
cp $TARGET_X86 $X86

echo "Success"
