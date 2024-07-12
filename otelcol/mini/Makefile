SRCS := go.mod go.sum $(wildcard *.go)
TARGETS := bin/otelcol bin/otelcol-linux-mips64

.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	rm -f $(TARGETS)

bin/otelcol: $(SRCS)
	go build -ldflags "-s -w" -o bin/otelcol
bin/otelcol-linux-mips64: $(SRCS)
	GOOS=linux GOARCH=mips64 go build -ldflags "-s -w" -o bin/otelcol-linux-mips64

$(SRCS): manifest.yaml
	go run go.opentelemetry.io/collector/cmd/builder@v0.104.0 --skip-compilation --config manifest.yaml
