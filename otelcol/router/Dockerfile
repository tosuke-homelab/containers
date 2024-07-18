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
# renovate: datasource=go depName=go.opentelemetry.io/collector/cmd/builder
ARG OTELCOL_BUILDER_VERSION=v0.104.0
RUN go install go.opentelemetry.io/collector/cmd/builder@${OTELCOL_BUILDER_VERSION}
WORKDIR /work
COPY . /work
RUN --mount=type=cache,target=/go/pkg/mod \
    builder --config manifest.yaml --skip-compilation
ARG TARGETARCH
WORKDIR /work/build
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOARCH=$TARGETARCH go build -ldflags "-s -w" -o /work/build/otelcol

FROM base AS artifact
COPY --from=builder /work/build/otelcol /otelcol
COPY --chmod=644 config.yaml /etc/otelcol/config.yaml
ENTRYPOINT ["/otelcol"]
CMD ["--config", "/etc/otelcol/config.yaml"]

