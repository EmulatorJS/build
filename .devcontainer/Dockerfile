FROM debian:latest

RUN apt-get update && apt-get install -y wget curl gpg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://ethanthesleepy.one/deb-repo/ethanthesleepyone.pgp.key | gpg --dearmor -o /etc/apt/keyrings/ethanthesleepyone.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/ethanthesleepyone.gpg] https://ethanthesleepy.one/deb-repo/ nodistro main" | tee /etc/apt/sources.list.d/ethanthesleepyone.list
RUN apt-get update && apt-get install -y p7zip-full binutils-mips-linux-gnu build-essential pkgconf python3 git zip libsdl2-dev emscripten jq
