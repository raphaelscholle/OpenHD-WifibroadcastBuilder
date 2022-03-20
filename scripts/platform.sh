#!/bin/bash

function setup_platform_env() {
	if [[ "${PLATFORM}" == "pi" ]]; then
		mkdir workdir
		mkdir workdir/${PLATFORM}
		mkdir workdir/tools

		# CCACHE workaround
		CCACHE_PATH=${PI_TOOLS_COMPILER_PATH}/../bin-ccache

		if [[ ! "$(ls -A ${CCACHE_PATH})" ]]; then
			mkdir -p ${CCACHE_PATH}
			pushd ${CCACHE_PATH}
			ln -s $(which ccache) arm-linux-gnueabihf-gcc
			ln -s $(which ccache) arm-linux-gnueabihf-g++
			ln -s $(which ccache) arm-linux-gnueabihf-cpp
			ln -s $(which ccache) arm-linux-gnueabihf-c++
			popd
		fi
		if [[ ${PATH} != *${CCACHE_PATH}* ]]; then
			export PATH=${CCACHE_PATH}:${PATH}
		fi

		export ARCH=arm
		PACKAGE_ARCH=armhf
		export CROSS_COMPILE=arm-linux-gnueabihf-
	fi

	if [[ "${PLATFORM}" == "jetson" ]]; then
		mkdir workdir
		mkdir workdir/${PLATFORM}
		mkdir workdir/tools

		WorkDir=$(pwd)/workdir
		Tools=$(pwd)/workdir/tools

		cd $Tools

		rm -Rf *
		wget -q --show-progress --progress=bar:force:noscroll http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
		tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
		export CROSS_COMPILE=$Tools/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

		export ARCH=arm64
		PACKAGE_ARCH=arm64
		export CROSS_COMPILE=arm-linux-aarch64-

	fi
}

