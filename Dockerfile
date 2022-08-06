FROM alpine:3.12 as builder
ARG FALCO=0.32.1
RUN apk add g++ gcc cmake cmake make libtool elfutils-dev musl-dev libelf-static linux-headers
COPY ./pdig /app/pdig
COPY ./libs /app/libs
RUN mkdir -p /app/pdig/build && cd /app/pdig/build && cmake -DMUSL_OPTIMIZED_BUILD=True .. && make
RUN wget https://download.falco.org/packages/bin/x86_64/falco-${FALCO}-static-x86_64.tar.gz && \
  tar -xvf  falco-${FALCO}-static-x86_64.tar.gz && \
  cd falco-${FALCO}-x86_64 && \
  cp -rv etc/falco /etc/falco && \
  cp -rv usr/bin/falco /usr/bin/falco && \
  chmod +x /usr/bin/falco && \
  cd .. && rm -fr falco-${FALCO}-x86_64 && rm falco-${FALCO}-static-x86_64.tar.gz

FROM golang:1.17.6-alpine AS gobuilder
WORKDIR /go/src/app
COPY sample-app .
RUN CGO_ENABLED=0 go build "-ldflags=-s -w" -o /app ${PWD} \
    && chmod +x /app

FROM golang:1.17.6-alpine AS trail
WORKDIR /go/src/trail
COPY trail .
RUN CGO_ENABLED=0 go build "-ldflags=-s -w" -o /trail ${PWD} \
    && chmod +x /trail

# falco/pdig need to run as root user
FROM gcr.io/distroless/static:latest
COPY --from=builder /usr/bin/falco /usr/bin/falco
COPY --from=builder /app/pdig/build/pdig /usr/bin/pdig
COPY --from=gobuilder /app /usr/bin/app
COPY --from=trail /trail /usr/bin/trail
COPY falco.yaml /etc/falco/falco.yaml
COPY falco_rules.yaml /etc/falco/falco_rules.yaml
ENTRYPOINT ["trail", "app"]