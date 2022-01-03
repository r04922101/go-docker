# syntax=docker/dockerfile:1.2
FROM golang:1.17-alpine AS compiler
WORKDIR /src
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go build -v -o /go/bin/main ./src/dependencies/main.go

FROM alpine
RUN addgroup --gid 1001 -S tony && \
    adduser -G tony --shell /bin/false --disabled-password -H --uid 1001 tony
COPY --from=compiler /go/bin/main /usr/local/bin/main
RUN chown tony:tony /usr/local/bin/main
USER tony
CMD ["/usr/local/bin/main"]