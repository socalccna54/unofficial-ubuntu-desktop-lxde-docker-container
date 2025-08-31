FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    supervisor \
    lxde \
    x11vnc \
    xvfb \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create Supervisor config directory
RUN mkdir -p /etc/supervisor/conf.d

# Embed supervisord.conf directly
RUN echo "[supervisord]\n\
nodaemon=true\n\
\n\
[program:x11vnc]\n\
command=/usr/bin/x11vnc -forever -usepw -create\n\
autostart=true\n\
autorestart=true\n\
priority=10\n\
\n\
[program:xvfb]\n\
command=/usr/bin/Xvfb :0 -screen 0 1024x768x16\n\
autostart=true\n\
autorestart=true\n\
priority=20\n\
\n\
[program:startlxde]\n\
command=/usr/bin/startlxde\n\
autostart=true\n\
autorestart=true\n\
priority=30\n" \
> /etc/supervisor/conf.d/supervisord.conf

# Expose VNC port
EXPOSE 5900

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
