FROM alpine AS builder
RUN apk add --no-cache curl unzip
ARG CONSUL_VERSION=1.3.0
RUN curl -LO https://releases.hashicorp.com/consul-esm/${CONSUL_VERSION}/consul-esm_${CONSUL_VERSION}_linux_amd64.zip \
 && unzip consul-esm_${CONSUL_VERSION}_linux_amd64.zip -d /

FROM scratch
LABEL maintainer="Tristan Morgan <tristan@vibrato.com.au>"
LABEL Description="HashiCorp Consul in a single binary Container"

WORKDIR /
COPY --from=builder /consul-esm /
ENTRYPOINT ["/consul-esm"]
CMD ["agent","-server","-dev","-client=0.0.0.0"]
