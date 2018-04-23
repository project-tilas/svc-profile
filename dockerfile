FROM alpine:3.7

EXPOSE 8080

ADD svc-profile /bin/svc-profile

ENTRYPOINT "svc-profile"