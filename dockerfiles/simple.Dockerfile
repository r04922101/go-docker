FROM golang:1.17-alpine
WORKDIR /src
COPY ./src/simple ./
RUN go build -v -o /go/bin/main ./main.go
ENTRYPOINT ["/go/bin/main"]