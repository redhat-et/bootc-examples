## Bootable container images with autoupdate systemd service

This repository shows an example to customize a base bootc image with desired features.
An autoupdate service and passwordless sudo are added to a base bootc image.
Embedded in this repository is also a quadlet (systemd managed podman container) to run a local AI chat application,
as well as a quadlet to run a caddy web-server application. Use the examples from this repository to create your own
customized bootc-enabled operating system image. 

### Get started with a bootc-enabled virtual machine

To launch a bootc-enabled virtual machine with KVM/QEMU, see [virt-install document](./virt-install.md)

### Customize the bootc image

To build a custom bootc image derived from `quay.io/centos-bootc/fedora-bootc:eln`, customize the
[Containerfile](./Containerfile) as desired, then run

```bash
podman build -t quay.io/your-repo/your-os:tag .
podman push quay.io/your-repo/your-os:tag
```

```bash
ssh -i ~/.ssh/your-key fedora@vm-ipaddress

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

Now that the instance is bootc-enabled,
follow the above [example to update a bootc system with a custom image](#update-bootc-system-to-a-custom-os-image).
However, at this time, you must not mix `centos/rhel` based systems with `fedora` based systems. In the future this may not be an issue.

The base images available currently are listed below.

#### Base bootc images 

```bash
# for customizing CentOS or RHEL OS image
FROM quay.io/centos-bootc/centos-bootc:stream9

# for customizing cloud images (AMIs) that are CentOS or RHEL based
FROM quay.io/centos-bootc/centos-bootc-cloud:stream9

# for customizing fedora OS image
FROM quay.io/centos-bootc/fedora-bootc:eln
```

### Auto-update with bootable OCI image

With podman-autoupdate the system is updated by pushing a new image to
a registry - when it changes, the host will automatically fetch it and reboot with
`bootc upgrade --apply`. To rebase to a fedora-bootc image that has the podman auto-update service enabled:

```bash
bootc switch quay.io/sallyom/fedora-bootc:autoupdate
```

### Benefits of bootc

OCI image tools can be utilized to streamline and simplify OS updates.
Mostly immutable (read-only) systems discourages infrastructure drift with atomic upgrades.

Instead of delivering OS updates in a traditional way, bootc packages and delivers
OS images as OCI objects. All the OCI tools you are familiar with can now be used to manage the operating system.
With fleets of systems, this centralized pull-based model simplifies updates.

If you are intrigued, you might also check out:

2. [CoreOS layering examples](https://github.com/coreos/layering-examples)
3. [Universal Blue](https://universal-blue.org/)
4. [OSTree](https://ostreedev.github.io/ostree/#operating-systems-and-distributions-using-ostree)
5. [bootc](https://github.com/containers/bootc/tree/main)

### How do I run the python AI example?

Embedded in the bootable image is `/etc/containers/systemd/chatapp.container`
`quadlet` will create a systemd service, `chatapp` that includes an LLM, python, and an example script.
This service manages a podman container that runs `quay.io/sallyom/chatbot:model-service`.

The `chatapp` service will be running in a machine booted from
`quay.io/sallyom/fedora-bootc:autoupdate` `quay.io/sallyom/fedora-bootc:autoupdate-arm`.
Interact with the model by navigating the browser at `http://machine-ip:7860`. 

