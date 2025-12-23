# syntax=docker/dockerfile:1

ARG target
ARG baseimage=distroless

FROM --platform=$BUILDPLATFORM otel/opentelemetry-collector-builder:0.114.0 AS ocb

FROM --platform=$BUILDPLATFORM golang:1.25 AS builder
COPY --from=ocb /usr/local/bin/ocb /usr/local/bin/ocb

FROM --platform=$BUILDPLATFORM builder AS generate
WORKDIR /work
ARG target
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=bind,source=${target}/manifest.yaml,target=manifest.yaml \
    ocb --config manifest.yaml --skip-compilation --skip-get-modules
WORKDIR /work/build
COPY ${target}/go.sum go.sum
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod tidy

FROM scratch AS gosum
COPY --from=generate /work/build/go.sum go.sum

FROM --platform=$BUILDPLATFORM generate AS build
ARG TARGETOS
ARG TARGETARCH
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags "-s -w" -o /work/build/otelcol

# systemd based image
FROM debian:bookworm-slim AS base-systemd
RUN --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get install -y \
        systemd \
        ca-certificates
ARG UID=10001
RUN adduser --uid ${UID} --disabled-password --gecos "" appuser
USER appuser

# dstroless based image
FROM gcr.io/distroless/static-debian12 AS base-distroless

FROM base-${baseimage} AS app
ARG target
COPY --chmod=644 ${target}/config.yaml /etc/otelcol/config.yaml
COPY --from=build /work/build/otelcol /otelcol
ENTRYPOINT ["/otelcol"]
CMD ["--config", "/etc/otelcol/config.yaml"]

FROM scratch AS bin
COPY --from=build /work/build/otelcol otelcol

FROM app AS final

