#!/usr/bin/env bash

docker build \
	--build-arg ARCH=arm64 \
	--build-arg CROSS_COMPILE=/bin/aarch64-linux-gnu- \
	--build-arg KERNEL_VERSION=6.12.25 \
	-f docker/Dockerfile \
	--target=kernel \
	--output=type=local,dest=/tmp/out \
	.
