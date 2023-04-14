#!/bin/bash

# Variables
DIR=`readlink -f .`;
PARENT_DIR=`readlink -f ${DIR}/..`;

aarch64-4.9()
{
  if [ ! -d $PARENT_DIR/aarch64-linux-android-4.9 ]; then
    git clone https://github.com/johnt1989/toolchains -b aarch64-linux-android $PARENT_DIR/aarch64-linux-android-4.9
  fi
}

aarch64-elf-4.9()
{
  if [ ! -d $PARENT_DIR/aarch64-linux-elf-4.9 ]; then
    git clone https://github.com/johnt1989/toolchains -b aarch64-linux-elf $PARENT_DIR/aarch64-linux-elf-4.9
  fi
}

androideabi-4.9()
{
  if [ ! -d $PARENT_DIR/arm-linux-androideabi-4.9 ]; then
    git clone https://github.com/johnt1989/toolchains -b arm-linux-androideabi $PARENT_DIR/arm-linux-androideabi-4.9
  fi
}

clangdd()
{
  if [ ! -d $PARENT_DIR/clang ]; then
    git clone https://github.com/johnt1989/toolchains -b clang $PARENT_DIR/clang
  fi
}

export CLANG_PATH=$PARENT_DIR/clang/bin/
export ELF_PATH=$PARENT_DIR/aarch64-linux-elf-4.9/bin/
export PATH=${CLANG_PATH}:${ELF_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$PARENT_DIR/aarch64-linux-android-4.9/bin/aarch64-linux-android- CC=clang CXX=clang++
export CROSS_COMPILE_ARM32=$PARENT_DIR/arm-linux-androideabi-4.9/bin/arm-eabi-
export KBUILD_COMPILER_STRING=$(${PARENT_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export CXXFLAGS="$CXXFLAGS -fPIC"
export DTC_EXT=dtc
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Doc714-5S-V3"
export KBUILD_BUILD_HOST="UBUNtU"

clean()
{
  make CC="ccache clang" CXX="ccache clang++" clean
  make CC="ccache clang" CXX="ccache clang++" mrproper
  [ -d "out" ] && rm -rf out
}

build()
{
  [ ! -d "out" ] && mkdir out
  make CC="ccache clang" CXX="ccache clang++" O=out vendor/NX659J_defconfig
  make CC="ccache clang" CXX="ccache clang++" O=out

  [ -e out/arch/arm64/boot/Image.gz ] && cp out/arch/arm64/boot/Image.gz $(pwd)/out/Image.gz
  if [ -e out/arch/arm64/boot/Image.gz-dtb ]; then
    cp out/arch/arm64/boot/Image.gz-dtb $(pwd)/out/Image.gz-dtb

    find out/arch/arm64/boot/dts/vendor/qcom -name '*.dtb' -exec cat {} + > $(pwd)/out/dtb
  fi
}

anykernel3()
{
  if [ ! -d $PARENT_DIR/AnyKernel3 ]; then
    git clone https://github.com/osm0sis/AnyKernel3 $PARENT_DIR/AnyKernel3
  fi
  if [ -e out/arch/arm64/boot/Image.gz-dtb ]; then
    cp out/arch/arm64/boot/Image.gz-dtb $PARENT_DIR/AnyKernel3/zImage
  elif [ -e out/arch/arm64/boot/Image ]; then
    cp out/arch/arm64/boot/Image $PARENT_DIR/AnyKernel3/zImage
  fi
  if [ -e out/dtb ]; then
    cp out/dtb $PARENT_DIR/AnyKernel3/dtb
  fi
  cd $PARENT_DIR/AnyKernel3
  git reset --hard
  sed -i "s/ExampleKernel by osm0sis/NX659J kernel by Doc714/g" anykernel.sh
  sed -i "s/=maguro/=NX659J/g" anykernel.sh
  sed -i "s/=toroplus/=/g" anykernel.sh
  sed -i "s/=toro/=/g" anykernel.sh
  sed -i "s/=tuna/=/g" anykernel.sh
  sed -i "s/omap\/omap_hsmmc\.0\/by-name\/boot/soc\/1d84000\.ufshc\/by-name\/boot/g" anykernel.sh
  sed -i "s/backup_file/#backup_file/g" anykernel.sh
  sed -i "s/replace_string/#replace_string/g" anykernel.sh
  sed -i "s/insert_line/#insert_line/g" anykernel.sh
  sed -i "s/append_file/#append_file/g" anykernel.sh
  sed -i "s/patch_fstab/#patch_fstab/g" anykernel.sh
  sed -i "s/dump_boot/split_boot/g" anykernel.sh
  sed -i "s/write_boot/flash_boot/g" anykernel.sh
  zip -r9 $PARENT_DIR/d2q_kernel.zip * -x .git README.md *placeholder
  cd $DIR
}

aarch64-4.9
aarch64-elf-4.9
androideabi-4.9
clangdd
clean
build
anykernel3