# syntax=docker/dockerfile:1
ARG bird_version

FROM --platform=${BUILDPLATFORM} curlimages/curl:8.12.0 AS src
ARG bird_version
RUN curl -s -o bird.tar.gz https://bird.network.cz/download/bird-${bird_version}.tar.gz
RUN tar -xzf bird.tar.gz
RUN mv bird-${bird_version} bird

# linux/amd64
FROM gcr.io/distroless/base-nossl-debian12:debug AS base-linux-amd64

FROM --platform=${BUILDPLATFORM} debian:12-slim AS builder-linux-amd64
ENV TRIPLE=x86_64-linux-gnu
ENV GCC=gcc-x86-64-linux-gnu

# linux/arm64
FROM gcr.io/distroless/base-nossl-debian12:debug AS base-linux-arm64

FROM --platform=${BUILDPLATFORM} debian:12-slim AS builder-linux-arm64
ENV TRIPLE=aarch64-linux-gnu

# linux/mips
FROM --platform=${BUILDPLATFORM} debian:9-slim AS builder-linux-mips
COPY <<EOF /etc/apt/sources.list
deb http://archive.debian.org/debian stretch main
deb http://archive.debian.org/debian-security stretch/updates main
deb http://archive.debian.org/debian stretch-backports main
EOF
ENV TRIPLE=mips-linux-gnu

ARG TARGETOS
ARG TARGETARCH
FROM --platform=${BUILDPLATFORM} builder-${TARGETOS}-${TARGETARCH} AS build
RUN --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get install -y \
        build-essential \
        flex \
        bison \
        autoconf \
        ${GCC:-gcc-${TRIPLE}}
ENV \
    AS=${TRIPLE}-as \
    AR=${TRIPLE}-ar \
    CC=${TRIPLE}-gcc \
    CPP=${TRIPLE}-cpp \
    CXX=${TRIPLE}-g++ \
    LD=${TRIPLE}-ld

COPY --from=src /home/curl_user/bird /bird
WORKDIR /bird

RUN ./configure \
    --disable-client \
    --host=${BIRD_HOST:-$TRIPLE} \
    --prefix=/usr/local/bird \
    --sysconfdir=/etc/bird \
    --with-runtimedir=/run/bird \
    --with-protocols="bgp,rpki,bfd,pipe,static"
RUN make -j install

FROM scratch AS bin
COPY --from=build /usr/local/bird/sbin/ /

FROM base-${TARGETOS}-${TARGETARCH} AS image
COPY --from=build /usr/local/bird/sbin /usr/local/bird/sbin
ENV PATH=/usr/local/bird/sbin:$PATH
ENTRYPOINT ["/usr/local/bird/sbin/bird"]
CMD ["-f", "-c", "/etc/bird/bird.conf"]
