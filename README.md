## Bootable container images with autoupdate systemd service & an example AI development workflow

This is a bootable container image with Colin Walters's
[autonomous-podman-hello](https://gitlab.com/CentOS/cloud/sagano-examples/-/tree/main/autonomous-podman-hello?ref_type=heads), and also an
example systemd service that provides a local LLM and a python script that utilizes the LLM. The service includes podman-autoupdate to
enable iteration of the model and script with pushes to a container registry.

### Convert from AWS CentOS, RHEL (non-ostree based) system to a `bootc` enabled system.

This assumes you are running from a centOS 9 or RHEL 9 ec2 instance:
See [bootc install docs](https://github.com/containers/bootc/blob/main/docs/install.md#using-bootc-install-to-filesystem) for more info.

```bash
sudo su
podman run --rm --privileged -v /:/target \
             --pid=host --security-opt label=type:unconfined_t \
             quay.io/centos-bootc/centos-bootc-cloud:stream9 \
             bootc install-to-filesystem --no-signature-verification --replace=alongside /target
systemctl reboot
```

Note: When you ssh in again, the cloud user has changed from `ec2-user` to `cloud-user` in AWS instance. 
The system is now bootc enabled and tracking the given OCI image for updates
o

This example shows an immutable infrastructure model with bootable container images.
Instead of delivering OS updates in a traditional way, this packages and delivers
OS images as OCI objects.

### AutoUpdate with OCI image

With podman-autoupdate the system is updated by pushing a new image to
a registry - when it changes, the host will automatically fetch it and reboot with
`bootc upgrade --apply`. To rebase to a centos-bootc image that has the podman auto-update service enabled:

```bash
bootc switch --no-signature-verification quay.io/sallyom/centos-bootc:autoupdate-cloud
or
bootc upgrade --apply
```

### Benefits

OCI image tools can be utilized to streamline and simplify OS updates
Discourage infrastructure drift with atomic upgrades.

If you are intrigued, you might also check out:

2. [CoreOS layering examples](https://github.com/coreos/layering-examples)
3. [Universal Blue](https://universal-blue.org/)
4. [OSTree](https://ostreedev.github.io/ostree/#operating-systems-and-distributions-using-ostree)
5. [bootc](https://github.com/containers/bootc/tree/main)

### How do I run the python AI example?

Embedded in the bootable image is `/usr/share/containers/systemd/chatapp.container`
`quadlet` will create a systemd service, `chatapp` that includes an LLM, python, and an example script.
This service manages a podman container that runs `quay.io/sallyom/fedora-coreos-custom:chatapp`. 

The `chatapp` service will be running in a machine booted from
`quay.io/sallyom/fedora-coreos-custom:summitdemo`. Interact with the model by navigating the
browser at `http://machine-ip:5555`. 

To run the `chatapp` service as an unprivileged user, ssh into the system and run:

```bash
$ mkdir -p ~/.config/containers/systemd
$ sudo cp /usr/share/containers/systemd/chatapp.container ~/.config/containers/systemd/.
$ sudo chown -R core:core ~/.config/containers/systemd
$ systemctl --user daemon-reload
$ systemctl --user enable --now chatapp

```
