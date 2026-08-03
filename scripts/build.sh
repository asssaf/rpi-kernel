#!/usr/bin/env bash

: ${ARCH:=arm64}
: ${CROSS_COMPILE:=/bin/aarch64-linux-gnu-}
: ${KERNEL_VERSION:=6.18.39}
: ${KERNEL_COMMIT:=stable_20260724}
: ${DEFCONFIG:=bcm2711_defconfig}
: ${TARGET=kernel}
: ${OUTPUT_TAR:=""}
: ${OUTPUT_LOCAL:=""}

docker build \
	--build-arg "ARCH=${ARCH}" \
	--build-arg "CROSS_COMPILE=${CROSS_COMPILE}" \
	--build-arg "KERNEL_VERSION=${KERNEL_VERSION}" \
	--build-arg "KERNEL_COMMIT=${KERNEL_COMMIT}" \
	--build-arg "DEFCONFIG=${DEFCONFIG}" \
	-f docker/Dockerfile \
	--target "${TARGET}" \
        ${OUTPUT_TAR:+--output "type=tar,dest=$OUTPUT_TAR"} \
        ${OUTPUT_LOCAL:+--output "type=local,dest=$OUTPUT_LOCAL"} \
	.
