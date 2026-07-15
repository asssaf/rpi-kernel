#!/usr/bin/env bash

: ${ARCH:=arm64}
: ${CROSS_COMPILE:=/bin/aarch64-linux-gnu-}
: ${KERNEL_VERSION:=6.18.38}
: ${DEFCONFIG:=bcm2712_defconfig}
: ${TARGET=kernel}
: ${OUTPUT_TAR:=""}
: ${OUTPUT_LOCAL:=""}

docker build \
	--build-arg "ARCH=${ARCH}" \
	--build-arg "CROSS_COMPILE=${CROSS_COMPILE}" \
	--build-arg "KERNEL_VERSION=${KERNEL_VERSION}" \
	--build-arg "DEFCONFIG=${DEFCONFIG}" \
	-f docker/Dockerfile \
	--target "${TARGET}" \
        ${OUTPUT_TAR:+--output "type=tar,dest=$OUTPUT_TAR"} \
        ${OUTPUT_LOCAL:+--output "type=local,dest=$OUTPUT_LOCAL"} \
	.
