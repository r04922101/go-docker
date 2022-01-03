# syntax=docker/dockerfile:1.2
FROM golang:1.17-alpine AS compiler
WORKDIR /src
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

COPY ./src/dependencies ./
RUN go build -v -o /go/bin/main ./main.go

FROM alpine
COPY --from=compiler /go/bin/main /usr/local/bin/main
CMD ["/usr/local/bin/main"]