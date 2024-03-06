## From bootc base image, create an Amazon Machine Image (AMI)  file and launch an ec2 instance

### Create an AMI

Use [bootc-image-builder](https://github.com/osbuild/bootc-image-builder) to create an AMI file.
First, update the [config.json](./bootc-build/qcow2/config.json) with your public SSH key contents.

This command will build an AMI and upload the AMI to a given AWS s3 bucket. The bucket must exist within
your AWS account.

```bash
sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    -v $HOME/.aws:/root/.aws:ro \
    --env AWS_PROFILE=default \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type ami \
    --aws-ami-name centos-bootc-ami \
    --aws-bucket centos-bootc-bucket \
    --aws-region us-east-1 \
    <your-custom-bootc-image>
```

This command will build an AMI and save it to the local directory `bootc-build/output/image/disk.raw`

```bash
sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    -v $(pwd)/bootc-build/output:/output \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type ami \
    <your-custom-bootc-image>
```

The file will be created as `./bootc-build/output/image/disk.raw`

Then, to push to AWS s3 bucket & register the ami,

```bash
aws s3 cp $(pwd)/bootc-build/output/disk.raw s3://your-s3-bucket-name
aws ec2 import-snapshot --description "rhel94-bootc" --disk-container file://ami-container.json
# Now you can create an AMI from the snapshot in the AWS console
```

### Launch an ec2 instance with terraform

This assumes an AMI `centos-bootc-ami` exists in your AWS account and
you have terraform and AWS CLI `aws` installed on your local system.
There is a sample [terraform file](./terraform/main.tf). Customize this
based on the AWS account details. Then:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Accessing the instance

```
ssh -i /path/to/private/ssh-key root@ip-address
```

### Updating from the base image to a custom image

The [Containerfile](./Containerfile) describes how to create a derived OS image from the base
`quay.io/centos-bootc/centos-bootc:stream9` image.

To build the derived OS image, run from the root of this repository

```
podman build -t quay.io/yourname/your-os:tag .
podman push quay.io/your-repo/your-os:tag
```

To switch the system to a custom `bootc` target image, ssh into the machine and run

```
sudo bootc switch quay.io/your-repo/your-os:tag
```

The system will pull down the necessary layers, and upon reboot will be enabled with an autoupdate service
for the target `quay.io/your-repo/your-os:tag`.
