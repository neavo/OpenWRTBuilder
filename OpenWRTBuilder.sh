#!/bin/bash

echo
echo

REPOSITORY_URL="https://github.com/coolsnowwolf/lede"
REPOSITORY_BRANCH="master"
REPOSITORY_COMMIT_ID="97c30dc6200a1acd28a16e0f1651809afb25c72f"
CONFIG_FILE="https://raw.githubusercontent.com/neavo/OpenWRTBuilder/main/.config"

echo "========================================================================================="
echo "="
echo "=  REPOSITORY_URL : $REPOSITORY_URL"
echo "=  REPOSITORY_BRANCH : $REPOSITORY_BRANCH"
echo "=  REPOSITORY_COMMIT_ID : $REPOSITORY_COMMIT_ID"
echo "=  CONFIG_FILE : $CONFIG_FILE"
echo "="
echo "========================================================================================="

# 初始化系统
sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip libpython3-dev qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
sudo apt autoremove --purge
sudo apt clean

# 克隆源码
sudo rm -rf OpenWRT
git clone $REPOSITORY_URL -b $REPOSITORY_BRANCH OpenWRT

# 进入工作文件夹
cd OpenWRT

# 切换 Commit
if [ "$REPOSITORY_COMMIT_ID" != "lastest" ];then
    git checkout $REPOSITORY_COMMIT_ID
fi

# 启用 SSR Plus
sed -i "/helloworld/d" "feeds.conf.default"
echo "src-git helloworld https://github.com/fw876/helloworld.git" >> "feeds.conf.default"

# 修改默认账号密码为 root/root
sed -i 's/root:::0:99999:7:::/root:$1$CFXmlfB0$DVrgJi586PAQHopcp1NDs1:18473:0:99999:7:::/g' ./package/base-files/files/etc/shadow

# 更新组件库
./scripts/feeds update -a
./scripts/feeds install -a

# 下载配置
wget --compression=gzip $CONFIG_FILE -O .config

# 下载依赖
make defconfig
make download -j8

# 编译固件
make V=s -j$(nproc)

echo
echo
