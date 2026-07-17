ARG KERNEL_STAGE=kernel
ARG MODULES_STAGE=modules


FROM debian:trixie AS deps

ARG ARCH
RUN apt update
RUN apt install -y curl fakeroot git kernel-wedge quilt ccache flex bison libssl-dev dh-exec rsync libelf-dev bc crossbuild-essential-${ARCH} python3

ARG KERNEL_VERSION
ENV KERNEL_RPI_BRANCH="rpi-${KERNEL_VERSION%.*}.y"

RUN mkdir /linux
RUN curl -sSL https://api.github.com/repos/raspberrypi/linux/tarball/${KERNEL_RPI_BRANCH} | tar --strip-components=1 -C linux -xz

WORKDIR /linux

ARG CROSS_COMPILE
ARG DEFCONFIG

# create a .config file
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make $DEFCONFIG

# Use the kvm_guest config as the base defconfig, which is suitable for qemu
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make kvm_guest.config

ADD extra.config extra.config

RUN scripts/kconfig/merge_config.sh -m -r .config extra.config

# ensure dependencies are met
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make oldconfig


FROM deps AS build

ARG ARCH
ARG CROSSCOMPILE

# Build the kernel
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make Image -j$(nproc)


FROM build AS build-modules

ARG ARCH=ARCH

# Build the modules
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make modules -j$(nproc)
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make modules_install

RUN apt install -y kmod
ARG KERNEL_VERSION
RUN LOCAL_VERSION=$(awk -F "=" '/CONFIG_LOCALVERSION/ { gsub(/"/, ""); print $2 }' .config); depmod -a ${KERNEL_VERSION}${LOCAL_VERSION}


FROM scratch AS kernel

ARG ARCH
ARG KERNEL_VERSION

COPY --from=build linux/arch/${ARCH}/boot/Image /Image-${KERNEL_VERSION}
COPY --from=build linux/.config /config-${KERNEL_VERSION}
COPY --from=build linux/System.map /System.map-${KERNEL_VERSION}


FROM scratch AS modules

ARG KERNEL_VERSION

COPY --from=build-modules /lib/modules /lib/modules
COPY --from=build-modules linux/Module.symvers /Module.symvers-${KERNEL_VERSION}


FROM --platform=linux/arm64/v8 ${KERNEL_STAGE} AS kernel-stage
FROM --platform=linux/arm64/v8 ${MODULES_STAGE} AS modules-stage
FROM --platform=linux/amd64 ghcr.io/asssaf/vcore:aarch64 AS vcore
FROM --platform=linux/amd64 ghcr.io/asssaf/vcore-extra:aarch64 AS vcore-extra

FROM debian:trixie AS test

RUN apt update

RUN apt install -y qemu-system-arm qemu-efi-aarch64 qemu-utils cpio
RUN apt install -y sshpass

COPY scripts/run.sh /

COPY --from=kernel-stage /Image* /Image
RUN mkdir /initramfs
COPY --from=vcore / /initramfs/
COPY --from=vcore-extra / /initramfs/
COPY --from=modules-stage /* /initramfs/lib

RUN cd /initramfs && find . -print0 | cpio --null -ov -H newc | gzip > /initramfs.cpio.gz

RUN \
  KERNEL=/Image INITRD="/initramfs.cpio.gz" /run.sh & \
  until sshpass -p "password" ssh -o StrictHostKeychecking=no -p 2223 user@127.0.0.1 sudo poweroff; do sleep 5; done; \
