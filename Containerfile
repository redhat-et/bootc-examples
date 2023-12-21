FROM quay.io/centos-bootc/fedora-bootc:eln

# Copy OS configuration to usr - this adds automatic updates
# This also adds 2 quadlet files chatapp.container and hello.container
ADD usr usr
ADD wheel-passwordless-sudo /etc/sudoers.d/wheel-passwordless-sudo

#ADD cuda-rhel9.repo /etc/yum.repos.d/cuda-rhel9.repo

#add nvidia drivers (requires either a released rhel kernel in the base image or dkms) and cuda toolkit
#RUN dnf install -y nvidia-driver nvidia-gds cuda-toolkit && rm /var/log/*.log /var/lib/dnf -rf 
RUN dnf install -y vim 
