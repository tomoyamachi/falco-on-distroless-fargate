ARG FALCO=0.28.1
FROM alpine:3 as builder
RUN apk add g++ gcc cmake cmake make libtool elfutils-dev libelf-static linux-headers
COPY ./pdig /app/pdig
COPY ./libs /app/libs
RUN mkdir -p /app/pdig/build && cd /app/pdig/build && cmake -DMUSL_OPTIMIZED_BUILD=True .. && make
RUN wget https://download.falco.org/packages/bin/x86_64/falco-${FALCO}-x86_64.tar.gz && \
  tar -xvf  falco-${FALCO}-x86_64.tar.gz && \
  cd falco-${FALCO}-x86_64 && \
  cp -rv etc/falco /etc/falco && \
  cp -rv usr/bin/falco /usr/bin/falco && \
  chmod +x /usr/bin/falco && \
  cp -rv usr/share/falco /usr/share/falco && \
  cd .. && rm -fr falco-${FALCO}-x86_64 && rm falco-${FALCO}-x86_64.tar.gz

FROM golang:1.16.4-alpine AS gobuilder
WORKDIR /go/src/app
COPY sample-app .
RUN CGO_ENABLED=0 go build "-ldflags=-s -w" -o /app ${PWD} \
    && chmod +x /app

FROM golang:1.16.4-alpine AS starter
WORKDIR /go/src/starter
COPY starter .
RUN CGO_ENABLED=0 go build "-ldflags=-s -w" -o /starter ${PWD} \
    && chmod +x /starter

# falco/pdig needs to run as root user
FROM gcr.io/distroless/static:latest
COPY --from=builder /usr/bin/falco /usr/bin/falco
COPY --from=builder /app/pdig/build/pdig /usr/bin/pdig
COPY --from=builder /usr/share/falco /usr/share/falco
COPY --from=gobuilder /app /usr/bin/app
COPY --from=starter /starter /usr/bin/starter
COPY ./falco-setting /etc/falco
ENTRYPOINT ["starter","falco -u --pidfile /var/run/falco.pid", "pdig app"]