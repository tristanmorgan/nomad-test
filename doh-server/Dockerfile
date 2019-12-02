FROM alpine
WORKDIR /
COPY /doh-server /
COPY /doh-server.conf /
ENTRYPOINT ["/doh-server"]
CMD ["/doh-server", "-conf", "/doh-server.conf"]
