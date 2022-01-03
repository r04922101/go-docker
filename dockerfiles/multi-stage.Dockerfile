FROM golang:1.17-alpine AS compiler
WORKDIR /src
COPY ./src/simple ./
RUN go build -v -o /go/bin/main ./main.go

FROM alpine
COPY --from=compiler /go/bin/main /usr/local/bin/main
CMD ["/usr/local/bin/main"]