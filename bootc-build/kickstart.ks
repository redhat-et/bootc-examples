# Basic setup
text
network --bootproto=dhcp --activate

# Basic partitioning
clearpart --all --initlabel --disklabel=gpt
reqpart --add-boot
part / --grow --fstype xfs

# Here's where we reference the container image to install - notice the kickstart
# has no `%packages` section!  What's being installed here is a container image.
ostreecontainer --url quay.io/sallyom/centos-bootc:rhel94 --no-signature-verification

# we can inject the ssh key for the root account in the container but we can't
# get rid of this line unfortunately
rootpw secure
sshkey --username root "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCk9QKBm4nfox+NijF/DYwbS1MB84MD62ucw7aggBjjywTe0TaXogJn95BzT/3bHq8uPBWdx3/YZxXqKjfi/Ac8HG8v31q6DoNJdP6YVy3vx6K3SorhZZJzV2tXTwF3S3AIudTe7NocShoVaFzSIwmzmn7dk5kydcd74Bl4kLZrkUtaMNtRrw6Yadxk1Gktu5NrfHFlKRvtYpK3RVaF+mNyEebp7aXR6i4d1V715AB6jL0GssMgVcIO2xo0zx2H5R25C7JHlxtNPwdap846WfHxNQeH8Up7SM31D/8q+cZ4kjWGFPFti0Ok1vQIMDJbOPnnFvLJp+iTzOBwPSm/cTrp somalley@chandi.usersys.redhat.com"
reboot

firewall --disabled
services --enabled=sshd
