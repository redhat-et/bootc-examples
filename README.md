## Bootable container images with autoupdate systemd service & an example AI development workflow

This is a bootable container image with Colin Walters's
[autonomous-podman-hello](https://gitlab.com/CentOS/cloud/sagano-examples/-/tree/main/autonomous-podman-hello?ref_type=heads), and also an
example systemd service that provides a local LLM and a python script that utilizes the LLM. The service includes podman-autoupdate to
enable iteration of the model and script with pushes to a container registry.

### What is this?

This assumes you have already run the following (or the equivalent) from a fedora-coreos system:

```bash
sudo su
rpm-ostree rebase --bypass-driver ostree-unverified-registry:quay.io/sallyom/fedora-coreos-custom:summitdemo
systemctl reboot
# the system is now bootc enabled and tracking the given OCI image for updates
```

This example shows an immutable infrastructure model with bootable container images.
Instead of delivering OS updates in a traditional way, this packages and delivers
OS images as OCI objects. With podman-autoupdate the system is updated by pushing a new image to
a registry - when it changes, the host will automatically fetch it and reboot with
`bootc upgrade --apply`. 

```bash
bootc switch --target-no-signature-verification quay.io/sallyom/fedora-coreos-custom:summitdemo
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
