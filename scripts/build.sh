#!/usr/bin/env bash

docker build \
	--build-arg ARCH=arm64 \
	--build-arg CROSS_COMPILE=/bin/aarch64-linux-gnu- \
	--build-arg KERNEL_VERSION=6.12.25 \
	--build-arg "KERNEL_SOURCES_URL=http://tinycorelinux.net/16.x/aarch64/release/src/kernel/rpi-linux-6.12.25.tar.xz" \
	--build-arg "KERNEL_CONFIG_URL=http://tinycorelinux.net/16.x/aarch64/release/src/kernel/6.12.25-piCore-v8_.config.xz" \
	-f docker/Dockerfile \
	--target=kernel \
	--output=type=local,dest=/tmp/out \
	.
