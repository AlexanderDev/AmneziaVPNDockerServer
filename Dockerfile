FROM ubuntu:24.04

# Install OpenSSH Server itself
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y bash sudo openssh-server libgcrypt20 && \
    cd /etc/ssh && \
    rm ssh_host_ecdsa_key ssh_host_ecdsa_key.pub ssh_host_ed25519_key ssh_host_ed25519_key.pub ssh_host_rsa_key ssh_host_rsa_key.pub && \
    mkdir /var/run/sshd

# Preinstall packages for AmneziaVPN
COPY setup/install-docker.sh /tmp/setup/install-docker.sh
RUN DEBIAN_FRONTEND=noninteractive apt install -y lsof psmisc && \
    chmod +x /tmp/setup/install-docker.sh && \
    DEBIAN_FRONTEND=noninteractive /tmp/setup/install-docker.sh

# only for the debug purpose
# RUN DEBIAN_FRONTEND=noninteractive apt install -y mc nano screen htop net-tools

COPY setup /tmp/setup

RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

COPY authorized_keys /root/.ssh/authorized_keys

RUN chmod 600 /root/.ssh/authorized_keys && \
    chown root:root /root/.ssh/authorized_keys

# Run set-up script
RUN chmod +x /tmp/setup/*.sh && \
    DEBIAN_FRONTEND=noninteractive /tmp/setup/setup.sh

# Starting SSH-daemon
CMD ["/tmp/setup/start.sh"]
