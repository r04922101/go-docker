FROM golang:1.17-alpine AS compiler
WORKDIR /src
COPY ./ ./
RUN go build -v -o /go/bin/main ./src/simple/main.go

FROM alpine
COPY --from=compiler /go/bin/main /usr/local/bin/main
ENTRYPOINT ["/usr/local/bin/main"]