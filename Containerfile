FROM quay.io/centos-boot/fedora-tier-1:eln

# Copy our OS configuration - this adds automatic updates
ADD usr usr
# Remove OpenSSH, lock the root account, remove sudo - we don't want remote logins at all.
#RUN rpm -e openssh-{server,clients} && passwd -l root && rpm -e sudo sudo-python-plugin && ostree container commit
RUN ostree container commit
