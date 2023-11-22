## Bootable container images with autoupdate systemd service & an example AI development workflow

This is a bootable container image with Colin Walters's
[autonomous-podman-hello](https://gitlab.com/CentOS/cloud/sagano-examples/-/tree/main/autonomous-podman-hello?ref_type=heads), and also an
example systemd service that provides a local LLM and a python script that utilizes the LLM. The service includes podman-autoupdate to
enable iteration of the model and script with pushes to a container registry.


### What is this?

This assumes you have already run the following (or the equivalent) from a fedora-coreos system:

```bash
sudo su
rpm-ostree rebase --bypass-driver ostree-unverified-registry:quay.io/sallyom/fedora-coreos-custom:bootc
systemctl reboot
# the system is now bootc enabled and tracking the given OCI image for updates
```

This example shows an immutable infrastructure model with bootable container images.
Instead of delivering OS updates in a traditional way, this packages and delivers
OS images as OCI objects. With podman-autoupdate the system is updated by pushing a new image to
a registry - when it changes, the host will automatically fetch it and reboot with
`bootc upgrade --apply`. 

```bash
bootc switch --target-no-signature-verification quay.io/sallyom/fedora-coreos-custom:bootc
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

Embedded in the bootable image is `pyrunai.service` at `/usr/lib/systemd/system/pyrunai.service`
This service manages a single pod, `pyrunai` that includes an LLM, python, and an example script.
The image that runs, `quay.io/sallyom/pyrunai:latest` is a whopping 12.7 GB. 

To run the script:

```bash
$ mkdir -p ~/.config/systemd/user
$ sudo cp /usr/lib/systemd/system/pyrunai.service ~/.config/systemd/user/.
$ sudo chown -R ~/.config/systemd/user
$ systemctl --user enable --now pyrunai
# the image is 12.7GB, so will take awhile to download 
$ podman exec -it pyrunai python run-model.py
```
The script will prompt you to ask a question. 

This is for testing/development only, as you can see from the output below:

```bash
(app-root) sh-4.4# python run-model.py
Special tokens have been added in the vocabulary, make sure the associated word embeddings are fine-tuned or trained.
Please ask me anything: Who is the wealthiest person alive today?

Answer:
henry ford
Elapsed time: 0.9215 seconds

(app-root) sh-4.4# python run-model.py
Special tokens have been added in the vocabulary, make sure the associated word embeddings are fine-tuned or trained.
Please ask me anything: Write a poem about hockey

Answer:
The game of hockey is a game of skill and skill and skill. The ball is thrown and the goalie takes aim. The players run and the ball is passed and the goal is scored. The crowd cheers and the players cheer and the crowd roars. The game is a game of skill and skill and skill.
Elapsed time: 8.3379 seconds

(app-root) sh-4.4# python run-model.py
Special tokens have been added in the vocabulary, make sure the associated word embeddings are fine-tuned or trained.
Please ask me anything: What nation is the wealthiest in the world?

Answer:
u s of america
Elapsed time: 1.1560 seconds
```
