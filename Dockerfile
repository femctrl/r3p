FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl ca-certificates python3 && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/owenthereal/upterm/releases/latest/download/upterm_linux_amd64.tar.gz -o upterm.tar.gz && \
    tar -xzf upterm.tar.gz && \
    mv upterm /usr/local/bin/upterm && \
    chmod +x /usr/local/bin/upterm && \
    rm upterm.tar.gz

WORKDIR /app

RUN echo keepalive > index.html

EXPOSE 8080

CMD sh -c "upterm host --server ws://uptermd.upterm.dev:80 --force-command bash & python3 -m http.server ${PORT:-8080}"
