FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install LXDE (lightweight desktop), VNC, noVNC, and supervisor
RUN apt-get update \
 && apt-get install -y \
    lxde-core lxterminal \
    x11vnc xvfb \
    websockify novnc \
    supervisor \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Create a non-root user (optional)
RUN useradd -m -s /bin/bash ubuntu \
 && echo "ubuntu:ubuntu" | chpasswd \
 && adduser ubuntu sudo

# Setup noVNC web directory
RUN mkdir -p /opt/novnc \
 && cp -r /usr/share/novnc/* /opt/novnc/ \
 && ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Add Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 5901

CMD ["/usr/bin/supervisord", "-n"]
