FROM golang:alpine AS builder

RUN apk add --no-cache git

ENV LD_FLAGS="-s -w"
ENV CGO_ENABLED="0"
ARG GOOS="linux"
ENV GOOS=$GOOS
ENV GOARCH="amd64"

RUN go get -v -u -ldflags "${LD_FLAGS}" github.com/m13253/dns-over-https/doh-server

FROM scratch

COPY --from=builder /go/bin/doh-server /

# FROM scratch
WORKDIR /
# COPY /doh-server /
ENTRYPOINT ["/doh-server"]
