FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install LXDE, VNC, Supervisor, git, and utilities
RUN apt-get update && apt-get install -y --no-install-recommends lxde-core lxterminal x11vnc xvfb supervisor sudo wget curl net-tools git && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Install noVNC manually
RUN mkdir -p /opt/novnc && git clone https://github.com/novnc/noVNC.git /opt/novnc && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && ln -sf /opt/novnc/vnc.html /opt/novnc/index.html

# Supervisor config
RUN mkdir -p /etc/supervisor/conf.d && echo "[supervisord]\n\
nodaemon=true\n\
\n\
[program:Xvfb]\n\
command=/usr/bin/Xvfb :0 -screen 0 1024x768x16\n\
autostart=true\n\
autorestart=true\n\
priority=10\n\
\n\
[program:x11vnc]\n\
command=/usr/bin/x11vnc -display :0 -forever -nopw -listen 0.0.0.0 -rfbport 5900\n\
autostart=true\n\
autorestart=true\n\
priority=20\n\
\n\
[program:websockify]\n\
command=/opt/novnc/utils/websockify/run --web=/opt/novnc 80 localhost:5900\n\
autostart=true\n\
autorestart=true\n\
priority=30\n\
\n\
[program:lxde]\n\
command=/usr/bin/startlxde\n\
autostart=true\n\
autorestart=true\n\
priority=40\n\
user=ubuntu\n\
environment=DISPLAY=\":0\",HOME=\"/home/ubuntu\"\n" \
> /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 80 5900

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
