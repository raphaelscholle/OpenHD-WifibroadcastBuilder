#!/bin/bash

# Echo to stderr
echoerr() { echo "$@" 1>&2; }

function init() {
    rm -rf ${PACKAGE_DIR}
    mkdir -p ${PACKAGE_DIR}/usr/local/bin || exit 1
}

function package() {
    PACKAGE_NAME=openhd-wifibroadcast-${PLATFORM}

    VERSION="2.1-$(date '+%m%d')"

    rm ${PACKAGE_NAME}_${VERSION}_${PACKAGE_ARCH}.deb >/dev/null 2>&1
    if [[ "${PLATFORM}" == "pi" ]]; then
        fpm -a ${PACKAGE_ARCH} -s dir -t deb -n ${PACKAGE_NAME} -v ${VERSION} -C ${PACKAGE_DIR} \
                -d libpcap-dev \
		-d libsodium-dev \
	     -p $SRC_DIR/${PACKAGE_NAME}_VERSION_ARCH.deb || exit 1
    fi
    if [[ "${PLATFORM}" == "jetson" ]]; then

        fpm -a ${PACKAGE_ARCH} -s dir -t deb -n ${PACKAGE_NAME} -v ${VERSION} -C ${PACKAGE_DIR} \
               	-d libpcap-dev \
		-d libsodium-dev \
            -p $SRC_DIR/${PACKAGE_NAME}_VERSION_ARCH.deb || exit 1
    fi

    #
    # You can build packages and test them locally without tagging or uploading to the repo, which is only done for
    # releases. Note that we push the same kernel to multiple versions of the repo because there isn't much reason
    # to separate them, and it would create a bit of overhead to manage it that way.
    #

    if [[ "${ONLINE}" == "ONLINE" ]]; then
       
	if [[ "${PLATFORM}" == "jetson" ]]; then
	    git describe --exact-match HEAD >/dev/null 2>&1
            echo "Pushing package to OpenHD repository"
            cloudsmith push deb openhd/openhd-2-1/ubuntu/${DISTRO} ${PACKAGE_NAME}_${VERSION}_${PACKAGE_ARCH}.deb
        fi


        if [[ $? -eq 0 ]]; then
	    git describe --exact-match HEAD >/dev/null 2>&1
            echo "Pushing package to OpenHD repository"
            cloudsmith push deb openhd/openhd-2-1/raspbian/${DISTRO} ${PACKAGE_NAME}_${VERSION}_${PACKAGE_ARCH}.deb
        else
	    git describe --exact-match HEAD >/dev/null 2>&1
            echo "Pushing package to OpenHD testing repository"
            cloudsmith push deb openhd/openhd-2-1-testing/raspbian/${DISTRO} ${PACKAGE_NAME}_${VERSION}_${PACKAGE_ARCH}.deb
        fi
    fi
}


function post_processing() {
    unset ARCH CROSS_COMPILE
}
