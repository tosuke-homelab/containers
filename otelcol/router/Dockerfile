FROM debian:bookworm-slim AS base

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        systemd \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN usermod -a -G systemd-journal nobody
USER nobody

FROM --platform=$BUILDPLATFORM golang:1.22 AS builder
ARG TARGETARCH
WORKDIR /work
COPY go.mod go.sum /work
RUN --mount=type=cache,sharing=locked,target=/go/pkg/mod go mod download
COPY . /work
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOARCH=${TARGETARCH} go build -ldflags "-s -w" -o /work/otelcol

FROM base AS artifact
COPY --from=builder /work/otelcol /otelcol
COPY --chmod=644 config.yaml /etc/otelcol/config.yaml
ENTRYPOINT ["/otelcol"]
CMD ["--config", "/etc/otelcol/config.yaml"]

