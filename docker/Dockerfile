FROM debian:trixie AS deps

ARG ARCH
RUN apt update
RUN apt install -y curl fakeroot git kernel-wedge quilt ccache flex bison libssl-dev dh-exec rsync libelf-dev bc crossbuild-essential-${ARCH}

ARG KERNEL_VERSION
ENV KERNEL_FAMILY="${KERNEL_VERSION/.*/}.x"

RUN curl -sL https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_FAMILY}/linux-${KERNEL_VERSION}.tar.xz | tar -xvJ

WORKDIR /linux-${KERNEL_VERSION}

ARG CROSS_COMPILE

# create a .config file
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make defconfig

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
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make Image -j8


FROM build AS build-modules

ARG ARCH=ARCH
ARG KERNEL_VERSION

# Build the modules
RUN ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make modules modules_install

RUN apt install -y kmod
RUN depmod -a ${KERNEL_VERSION}


FROM scratch AS kernel

ARG ARCH
ARG KERNEL_VERSION

COPY --from=build linux-${KERNEL_VERSION}/arch/${ARCH}/boot/Image /Image-${KERNEL_VERSION}
COPY --from=build linux-${KERNEL_VERSION}/.config /config-${KERNEL_VERSION}
COPY --from=build linux-${KERNEL_VERSION}/System.map /System.map-${KERNEL_VERSION}


FROM scratch AS modules

ARG KERNEL_VERSION

COPY --from=build-modules /lib/modules /lib/modules
COPY --from=build linux-${KERNEL_VERSION}/Module.symvers /Module.symvers-${KERNEL_VERSION}
