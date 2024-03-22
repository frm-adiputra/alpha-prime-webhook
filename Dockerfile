# Dockerfile for https://github.com/adnanh/webhook
FROM golang:alpine AS build
LABEL author="Firmansyah Adiputra <frm.adiputra@gmail.com>"
WORKDIR /go/src/github.com/adnanh/webhook
ENV WEBHOOK_VERSION=2.8.1
RUN apk add --update -t build-deps curl libc-dev gcc libgcc
RUN curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
    tar -xzf webhook.tar.gz --strip 1
RUN go get -d -v
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/webhook

FROM debian:stable-slim
COPY --from=build /usr/local/bin/webhook /usr/local/bin/webhook
WORKDIR /etc/webhook
VOLUME ["/etc/webhook"]
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/webhook"]

ARG TARGETOS=linux
ARG TARGETARCH=amd64

ENV NOMAD_VERSION=1.7.5

# RUN curl -L --silent -o nomad.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip && \
#     unzip nomad.zip -d /usr/local/bin/

ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    nomad_${NOMAD_VERSION}_${TARGETOS}_${TARGETARCH}.zip
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS \
    nomad_${NOMAD_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
    nomad_${NOMAD_VERSION}_SHA256SUMS.sig

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    gnupg \
    unzip \
    git \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && gpg --keyserver pgp.mit.edu --keyserver keys.openpgp.org --keyserver keyserver.ubuntu.com --recv-keys "C874 011F 0AB4 0511 0D02 1055 3436 5D94 72D7 468F" \
    && gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS \
    && grep nomad_${NOMAD_VERSION}_${TARGETOS}_${TARGETARCH}.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c \
    && unzip -d /bin nomad_${NOMAD_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    && chmod +x /bin/nomad \
    && rm -rf "$GNUPGHOME" nomad_${NOMAD_VERSION}_${TARGETOS}_${TARGETARCH}.zip nomad_${NOMAD_VERSION}_SHA256SUMS nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
    && apt-get autoremove --purge --yes \
    gnupg \
    unzip \
    && rm -rf /var/lib/apt/lists/*
RUN nomad version
