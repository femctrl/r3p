FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RESOLUTION=1707x1607
ENV PORT=8080
ENV DISPLAY=:0
ENV VNC_PASSWORD=changeme

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xvfb x11vnc fluxbox supervisor \
    python3 python3-pip git wget ca-certificates xauth && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir websockify

RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC

RUN useradd -m -s /bin/bash novnc && \
    mkdir -p /home/novnc/.vnc && \
    chown -R novnc:novnc /home/novnc

RUN printf "[supervisord]\nnodaemon=true\n\n[program:xvfb]\ncommand=/usr/bin/Xvfb :0 -screen 0 1707x1607x24\nautostart=true\nautorestart=true\n\n[program:fluxbox]\ncommand=/usr/bin/fluxbox -display :0\nautostart=true\nautorestart=true\n\n[program:x11vnc]\ncommand=/usr/bin/x11vnc -display :0 -forever -shared -rfbport 5900 -rfbauth /home/novnc/.vnc/passwd\nautostart=true\nautorestart=true\n\n[program:novnc]\ncommand=/usr/local/bin/novnc.sh\nautostart=true\nautorestart=true\n" > /etc/supervisor/supervisord.conf

RUN printf "#!/bin/bash\nexec websockify --web=/opt/noVNC ${PORT} localhost:5900\n" > /usr/local/bin/novnc.sh && \
    chmod +x /usr/local/bin/novnc.sh

RUN printf "#!/bin/bash\nmkdir -p /home/novnc/.vnc\nx11vnc -storepasswd \"$VNC_PASSWORD\" /home/novnc/.vnc/passwd\nchmod 600 /home/novnc/.vnc/passwd\nchown -R novnc:novnc /home/novnc\nexec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf\n" > /usr/local/bin/startup.sh && \
    chmod +x /usr/local/bin/startup.sh

EXPOSE 8080

CMD ["/usr/local/bin/startup.sh"]
