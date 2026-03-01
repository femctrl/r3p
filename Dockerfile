FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl ca-certificates bash && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

EXPOSE 8080

CMD sh -c "ttyd -p ${PORT:-8080} -W bash"
