#!/usr/bin/env bash

: ${ARCH:=arm64}
: ${CROSS_COMPILE:=/bin/aarch64-linux-gnu-}
: ${KERNEL_VERSION:=6.18.38}
: ${DEFCONFIG:=bcm2711_defconfig}
: ${TARGET=kernel}
: ${KERNEL_STAGE:=""}
: ${MODULES_STAGE:=""}
: ${OUTPUT_TAR:=""}
: ${OUTPUT_LOCAL:=""}

docker build \
	--build-arg "ARCH=${ARCH}" \
	--build-arg "CROSS_COMPILE=${CROSS_COMPILE}" \
	--build-arg "KERNEL_VERSION=${KERNEL_VERSION}" \
	--build-arg "DEFCONFIG=${DEFCONFIG}" \
	${KERNEL_STAGE:+--build-arg "KERNEL_STAGE=${KERNEL_STAGE}"} \
	${MODULES_STAGE:+--build-arg "MODULES_STAGE=${MODULES_STAGE}"} \
	-f docker/Dockerfile \
	--target "${TARGET}" \
        ${OUTPUT_TAR:+--output "type=tar,dest=$OUTPUT_TAR"} \
        ${OUTPUT_LOCAL:+--output "type=local,dest=$OUTPUT_LOCAL"} \
	--progress=plain \
	.
