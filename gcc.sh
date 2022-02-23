#!/usr/bin/env bash
#
# Copyright (C) 2021 a aliciahouse property
#

echo "Downloading few Dependecies . . ."
# Kernel Sources
git clone --depth=1 https://${GIT_USER}:${GIT_TOKEN}@github.com/rubyzee/android_kernel_xiaomi_mt6768 $KERNEL_BRANCH $DEVICE_CODENAME
git clone --depth=1 https://github.com/aliciahouse/aarch64-linux-gnu GCC64
git clone --depth=1 https://github.com/aliciahouse/arm-linux-gnueabi GCC32

# Main Declaration
KERNEL_NAME=$(cat "$KERNEL_ROOTDIR/arch/arm64/configs/$DEVICE_DEFCONFIG" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
KERNEL_ROOTDIR=$(pwd)/$DEVICE_CODENAME
ZIPNAME=[DATE2]$KERVER[AliceGCC]$KERNEL_NAME[R-OSS]-$HASH.zip
DEVICE=$DEVICE
DEVICE_DEFCONFIG=$DEVICE_DEFCONFIG
GCC64_DIR=$(pwd)/GCC64
GCC32_DIR=$(pwd)/GCC32
export KBUILD_BUILD_USER=Alicia
export KBUILD_BUILD_HOST=XZI-TEAM
CLANG_VER="$("$CLANG_ROOTDIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
GCC_VER=$("$GCC64_DIR"/bin/aarch64-elf-gcc --version | head -n 1)
export KBUILD_COMPILER_STRING="$GCC_VER"
export CROSS_COMPILE_ARM32=$GCC32_DIR/bin/arm-eabi-
export CROSS_COMPILE=$GCC32_DIR/bin/aarch64-elf-
IMAGE=$(pwd)/$DEVICE_CODENAME/out/arch/arm64/boot/Image.gz-dtb
MD5CHECK=$(md5sum "${ZIP}" | cut -d' ' -f1)
SHA1CHECK=$(sha1sum "${ZIP}" | cut -d' ' -f1)
DATE=$(date +"%F-%S")
DATE2=$(date +"%m%d")
START=$(date +"%s")
DTB=$(pwd)/$DEVICE_CODENAME/out/arch/arm64/boot/dts/mediatek/mt6768.dtb
DTBO=$(pwd)/$DEVICE_CODENAME/out/arch/arm64/boot/dtbo.img
PATH="${PATH}:${GCC64_DR}/bin:${GCC32_DIR}/bin"

#Check Kernel Version
KERVER=$(make kernelversion)
HASH="$(git log --pretty=format:'%h' -n1)"
HeadCommitId="$(git log --pretty=format:'%h' -n1)"
HeadCommitMsg="$(git log --pretty=format:'%s' -n1)"

# Telegram
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"

tg_post_msg() {
  curl -s -X POST "$BOT_MSG_URL" -d chat_id="$TG_CHAT_ID" \
  -d "disable_web_page_preview=true" \
  -d "parse_mode=html" \
  -d text="$1"

}

# Post Main Information
tg_post_msg "<b>🔨 Build Triggered</b>%0A%0AKernel Name : <code>${KERNEL_NAME}</code>%0A%0ADevice : <code>${DEVICE}</code>%0A%0ADevice Codename : <code>${DEVICE_CODENAME}</code>%0A%0AKernel Version : <code>${KERVER}</code>%0A%0ABuild Date : <code>${DATE}</code>%0A%0ABuilder Name : <code>${KBUILD_BUILD_USER}</code>%0A%0ABuilder Host : <code>${KBUILD_BUILD_HOST}</code>%0A%0ADevice Defconfig: <code>${DEVICE_DEFCONFIG}</code>%0A%0ACompile Used : <code>${KBUILD_COMPILER_STRING}</code>"

# Compile
compile(){
tg_post_msg "<b>xKernelCompiler:</b><code>Compilation has started</code>"
cd ${KERNEL_ROOTDIR}
make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
make -j$(nproc) ARCH=arm64 O=out \
           LD=ld.lld \
           AR=aarch64-elf-ar  \
           NM=llvm-nm \
           CROSS_COMPILE=aarch64-elf- \
           CROSS_COMPILE_ARM32=arm-eabi- 

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi

  git clone --depth=1 https://github.com/aliciahouse/AnyKernel3 -b mt6768 AnyKernel
	cp $IMAGE AnyKernel
    cp $DTBO AnyKernel
    mv $DTB AnyKernel/dtb
    
}

# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TG_TOKEN/sendDocument" \
        -F chat_id="$TG_CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="✅ <b>Build Success</b>%0A- <code>$((DIFF / 60)) minute(s) $((DIFF % 60)) second(s) </code>%0A%0A<b>MD5 Checksum</b>%0A- <code>$MD5CHECK</code>%0A%0A<b>SHA1 Checksum</b>%0A- <code>$SHA1CHECK</code>%0A%0A<b>Under Commit Id : Message</b>%0A- <code>${HeadCommitId}</code> : <code>${HeadCommitMsg}</code>%0A%0A<b>Compilers</b>%0A$KBUILD_COMPILER_STRINGS%0A%0A<b>Zip Name</b>%0A- <code>$ZIP</code>"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id="$TG_CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="❌ Build failed to compile after $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</b>"
    exit 1
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 $ZIPNAME *
    cd ..
}
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
