FROM --platform=$BUILDPLATFORM debian:latest
ARG TARGETARCH
ARG BUILDPLATFORM

RUN echo "Target: $TARGETARCH"
RUN echo "Build: $BUILDPLATFORM"

RUN apt-get update && apt-get install -y wget curl gpg p7zip-full binutils-mips-linux-gnu build-essential pkgconf python3 git zip libsdl2-dev jq
