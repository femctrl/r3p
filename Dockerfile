FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive RESOLUTION=1707x1607 PORT=8080 VNC_PASSWORD=changeme
RUN apt-get update && apt-get install -y --no-install-recommends x11vnc xvfb fluxbox python3-pip git supervisor wget ca-certificates xauth && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir websockify
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && git clone --depth 1 https://github.com/novnc/websockify /opt/noVNC/utils/websockify || true
RUN useradd -m -s /bin/bash novnc && mkdir -p /home/novnc/.vnc && chown -R novnc:novnc /home/novnc
RUN mkdir -p /etc/supervisor/conf.d
RUN bash -lc 'cat > /etc/supervisor/supervisord.conf <<EOF
[supervisord]
nodaemon=true

[program:xvfb]
command=/usr/bin/Xvfb :0 -screen 0 ${RESOLUTION}x24
autostart=true
autorestart=true
priority=10
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr

[program:fluxbox]
command=/usr/bin/fluxbox -display :0
autostart=true
autorestart=true
priority=20
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr

[program:x11vnc]
command=/usr/bin/x11vnc -display :0 -forever -shared -rfbport 5900 -rfbauth /home/novnc/.vnc/passwd
autostart=true
autorestart=true
priority=30
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr

[program:novnc]
command=/usr/local/bin/novnc.sh
autostart=true
autorestart=true
priority=40
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
EOF'
RUN bash -lc 'cat > /usr/local/bin/novnc.sh <<'SH'
#!/bin/bash
exec websockify --web=/opt/noVNC ${PORT} localhost:5900
SH
RUN bash -lc 'cat > /usr/local/bin/startup.sh <<'SH'
#!/bin/bash
mkdir -p /home/novnc/.vnc
if [ -n "$VNC_PASSWORD" ]; then
  x11vnc -storepasswd "$VNC_PASSWORD" /home/novnc/.vnc/passwd
  chmod 600 /home/novnc/.vnc/passwd
fi
chown -R novnc:novnc /home/novnc
export DISPLAY=:0
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
SH
RUN chmod +x /usr/local/bin/novnc.sh /usr/local/bin/startup.sh
EXPOSE 8080
CMD ["/usr/local/bin/startup.sh"]
