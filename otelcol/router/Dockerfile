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
ARG OTELCOL_BUILDER_VERSION=v0.105.0
ARG TARGETARCH
RUN --mount=type=cache,sharing=locked,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go install go.opentelemetry.io/collector/cmd/builder@${OTELCOL_BUILDER_VERSION}
WORKDIR /work
COPY . /work
RUN --mount=type=cache,sharing=locked,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    builder --config manifest.yaml

FROM base AS artifact
COPY --from=builder /work/build/otelcol /otelcol
COPY --chmod=644 config.yaml /etc/otelcol/config.yaml
ENTRYPOINT ["/otelcol"]
CMD ["--config", "/etc/otelcol/config.yaml"]

