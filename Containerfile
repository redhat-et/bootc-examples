FROM quay.io/fedora/fedora-coreos:stable

# Copy our OS configuration - this adds automatic updates
ADD usr usr
ADD fed38copr.repo /etc/yum.repos.d/fedora-bootc.repo 
# Remove OpenSSH, lock the root account, remove sudo - we don't want remote logins at all.
#RUN rpm -e openssh-{server,clients} && passwd -l root && rpm -e sudo sudo-python-plugin && ostree container commit
RUN rpm-ostree install bootc && \
    rm -rf /var/cache && \
    ostree container commit
