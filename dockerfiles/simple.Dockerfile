FROM golang:1.17-alpine
WORKDIR /src
COPY ./ ./
RUN go build -v -o /go/bin/main ./src/simple/main.go
ENTRYPOINT ["/go/bin/main"]