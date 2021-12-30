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
COPY --from=compiler /go/bin/main /usr/local/bin/main
ENTRYPOINT ["/usr/local/bin/main"]