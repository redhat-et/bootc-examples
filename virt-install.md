## From bootc base image, create a qcow2 file and launch a virtual machine

This example assumes that `virt-manager` is installed, along with `qemu/kvm` and `libvirt`. 

### Create a qcow2 file

Use [bootc-image-builder](https://github.com/osbuild/bootc-image-builder) to create a `qcow2` file.
First, update the [config.json](./bootc-build/config.json) with your public SSH key contents.

```bash
sudo podman run --rm -it \
    --privileged --pull=newer \
    --security-opt label=type:unconfined_t \
    -v $(pwd)/bootc-build/config.json:/config.json \
    -v $(pwd)/bootc-build/output:/output \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type qcow2 \
    --config /config.json \
    quay.io/centos-bootc/fedora-bootc:eln
```

The file will be created as `./bootc-build/output/qcow2/disk.qcow2`

### Launch a virtual machine with `virt-install`

```bash
sudo virt-install \
    --name fedora-bootc \
    --vcpus 4 \
    --memory 4096 \
    --import --disk ./bootc-build/output/qcow2/disk.qcow2,format=qcow2 \
    --os-variant fedora-eln
```

### Accessing the virtual machine

If the qcow2 file was built with the example [config.json](./bootc-build/config.json), you can access the system with

```
sudo virsh domifaddr fedora-bootc (to find the machine ip-address)
ssh -i /path/to/private/ssh-key fedora@ip-address-from-above
```

### Updating from the base image to a custom image

The [Containerfile](./Containerfile) describes how to create a derived OS image from the base `quay.io/centos-bootc/fedora-bootc:eln` image.
This Containerfile adds passwordless sudo as well as an autoupdate systemd service. With this service, any push to the bootc targeted image
will result in the virtual machine rebooting into the updated OS.

To build the derived OS image, run from the root of this repository

```
podman build -t quay.io/yourname/your-os:tag .
podman push quay.io/your-repo/your-os:tag
```

To switch the system to a custom `bootc` target image, ssh into the machine and run

```
sudo bootc switch quay.io/your-repo/your-os:tag
# quay.io/sallyom/fedora-coreos:autoupdate is a public image built from this repository
```

The system will pull down the necessary layers, and upon reboot will be enabled with an autoupdate service
for the target `quay.io/your-repo/your-os:tag`.
