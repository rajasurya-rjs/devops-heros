FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
      systemd systemd-sysv dbus \
      nginx \
      iproute2 iputils-ping dnsutils traceroute net-tools curl \
      passwd adduser tree vim less procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* || true
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd"]
