FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y tmate curl python3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN echo keepalive > index.html

EXPOSE 8080

CMD sh -c "tmate -F & python3 -m http.server ${PORT:-8080}"
