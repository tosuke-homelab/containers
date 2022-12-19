FROM debian:bullseye-slim as builder

ARG BIRD_VERSION=2.0.10
WORKDIR /work

RUN apt-get update
RUN apt-get install -y \
    curl \
    make \
    iproute2 \
    flex \
    bison \
    libncurses5-dev \
    libreadline-dev \
    libssh-dev

RUN curl -s -O https://bird.network.cz/download/bird-${BIRD_VERSION}.tar.gz && \
    tar xzf bird-${BIRD_VERSION}.tar.gz

WORKDIR /work/bird-${BIRD_VERSION}

RUN ./configure \
        --prefix=/usr/local/bird \
        --sysconfdir=/etc/bird \
        --with-runtimedir=/run/bird \
        --with-protocols=bgp,rpki,bfd,pipe,static && \
    make && \
    make install

FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y \
        iproute2 \
        libreadline8 \
        libssh-4 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bird /usr/local/bird
COPY --from=builder /etc/bird /etc/bird
COPY --from=builder /etc/iproute2 /etc/iproute2

ENV PATH=/usr/local/bird/sbin:$PATH

ENTRYPOINT [ "/usr/local/bird/sbin/bird", "-f" ]