## Bootable container images with autoupdate systemd service

This repository shows an example to customize a base bootc image with desired features.
This repository also contains quadlet files (for running systemd managed podman containers) to embed an AI chat application,
Use the examples from this repository to create your own customized bootc-enabled operating system image. 

### Get started with a bootc-enabled virtual machine

To launch a bootc-enabled virtual machine with KVM/QEMU, see [virt-install document](./virt-install.md)

### Customize the bootc image

To build a custom bootc image derived from `quay.io/centos-bootc/centos-bootc:stream9`, customize the
[Containerfile](./Containerfile) as desired, then run

```bash
podman build -t quay.io/your-repo/your-os:tag .
podman push quay.io/your-repo/your-os:tag
```

```bash
ssh -i ~/.ssh/your-key centos@vm-ipaddress

sudo bootc switch quay.io/your-repo/your-os:tag
sudo reboot
```

### Convert from AWS CentOS, RHEL (non-ostree based) system to a `bootc` enabled system.

From a centOS 9 or RHEL 9 ec2 instance:
See [bootc install docs](https://github.com/containers/bootc/blob/main/docs/install.md#using-bootc-install-to-filesystem) for more info.

```bash
ssh ec2-user@vm-ipaddress
sudo su
podman run --rm --privileged -v /:/target \
             --pid=host --security-opt label=type:unconfined_t \
             quay.io/centos-bootc/centos-bootc-cloud:stream9 \
             bootc install to-filesystem --replace=alongside /target
systemctl reboot
```

**Note:** When you ssh in again, the cloud user has changed from `ec2-user` to `cloud-user` in AWS instance. 
The system is now bootc enabled and tracking the given OCI image for updates

#### Base bootc images 

The base images available currently are listed below.

```bash
# for customizing CentOS or RHEL OS image
FROM quay.io/centos-bootc/centos-bootc:stream9

# for customizing cloud images (AMIs) that are CentOS or RHEL based
FROM quay.io/centos-bootc/centos-bootc-cloud:stream9

# for customizing fedora OS image
FROM quay.io/centos-bootc/fedora-bootc:eln
```

### Auto-update with bootable OCI image

The base bootc images are configured with podman-autoupdate.
With podman-autoupdate the system is updated by pushing a new bootc OCI image to
a registry - on a timer, when the image digest changes, the host will automatically fetch it and reboot with
`bootc upgrade --apply`.

To switch the bootc image that your system is tracking, run

```bash
bootc switch quay.io/your/newimage:custom
```

Upon a reboot, the system will now be running with your custom OS.
At the time of this writing, it is not possible to switch from a CentOS based bootc image to a Fedora based image, or vice versa. 

### How do I run the python chatbot AI example?

Embedded in the bootable image built from [bootc-build/Containerfile](./bootc-build/Containerfil) are quadlet files for running an AI powered chatbot.
The files `/etc/containers/systemd/chatbot.kube`, `/etc/containers/systemd/chatbot.yaml`, and `/etc/systemd/chatbot.image` result in
a systemd service, `chatbot` that includes an LLM, a model-service, and an example application.
This service manages a podman pod.

Interact with the application by navigating to the browser at `http://machine-ip:8080` or `http://machine-ip:8051` depending on which chatbot is embedded. 

