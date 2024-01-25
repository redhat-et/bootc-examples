FROM quay.io/centos-bootc/fedora-bootc:eln

ADD quadlets/chatbot-llama27b.container.example /etc/containers/systemd/chatapp.container
ADD wheel-passwordless-sudo /etc/sudoers.d/wheel-passwordless-sudo

#ADD cuda-rhel9.repo /etc/yum.repos.d/cuda-rhel9.repo

#add nvidia drivers (requires either a released rhel kernel in the base image or dkms) and cuda toolkit
#RUN dnf install -y nvidia-driver nvidia-gds cuda-toolkit && rm /var/log/*.log /var/lib/dnf -rf 
#RUN dnf install -y vim 
