FROM quay.io/cgwalters/centos-bootc-dev:stream9

# Copy OS configuration to usr - this adds automatic updates
# This also adds 2 quadlet files chatapp.container and hello.container
ADD usr usr

#ADD cuda-rhel9.repo /etc/yum.repos.d/cuda-rhel9.repo

#add nvidia drivers (requires either a released rhel kernel in the base image or dkms) and cuda toolkit
#RUN dnf install -y nvidia-driver nvidia-gds cuda-toolkit && rm /var/log/*.log /var/lib/dnf -rf 
RUN dnf install -y vim 

# If running in ec2 instance & started from quay.io/cgwalters/centos-bootc-dev:stream9, you should not need to configure users & keys
# Uncomment to build non-cloud image with autoupdate script
# root.keys is contents of ~/.ssh/your-public-ssh-key file
#COPY root.keys /usr/etc-system/root.keys
#RUN touch /etc/ssh/sshd_config.d/30-auth-system.conf; \
#    mkdir -p /usr/etc-system/; \
#    echo 'AuthorizedKeysFile /usr/etc-system/%u.keys' >> /etc/ssh/sshd_config.d/30-auth-system.conf; \
#    chmod 0600 /usr/etc-system/root.keys
