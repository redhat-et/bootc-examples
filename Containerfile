FROM quay.io/centos-bootc/fedora-bootc:eln

ADD https://raw.githubusercontent.com/redhat-et/locallm/main/chatbot/quadlet/chatbot.kube.example /etc/containers/systemd/chatbot.kube
ADD https://raw.githubusercontent.com/redhat-et/locallm/main/chatbot/quadlet/chatbot.yaml /etc/containers/systemd/chatbot.yaml

# Change the root password
RUN echo "root:secure" | chpasswd
ADD wheel-passwordless-sudo /etc/sudoers.d/wheel-passwordless-sudo

RUN dnf install -y podman
RUN podman pull quay.io/sallyom/chatbot:model-service
RUN podman pull quay.io/sallyom/models:llama2-7b-gguf
RUN podman pull quay.io/sallyom/chatbot:inference
#ADD cuda-rhel9.repo /etc/yum.repos.d/cuda-rhel9.repo

#add nvidia drivers (requires either a released rhel kernel in the base image or dkms) and cuda toolkit
#RUN dnf install -y nvidia-driver nvidia-gds cuda-toolkit && rm /var/log/*.log /var/lib/dnf -rf 
#RUN dnf install -y vim 
