#!/bin/bash
help() {
    cat << EOF

# Usage
./this-script help

# Commands
help - Print this help message
initialise - terragrunt apply - (re)init infrastructure
reinitialise - destroy and init the droplet - for testing cloud-init or whatever
hibernate - terragrunt destroy *all but persistent storage*
die - terragrunt destroy *all*
ping - pong

EOF
}

initialise() {
    echo "Applying infrastructure"
    echo

    terragrunt apply
}

reinitialise() {
    echo "Destroying droplet"
    echo

    terragrunt destroy -target digitalocean_droplet.concourse_droplet

    echo "Initialising droplet"
    echo

    terragrunt apply
}

hibernate() {
    echo "Planning destruction of everything but persistent volume"
    echo

    # Destroy all resources except persistent storage
    # https://github.com/hashicorp/terraform/issues/2253#issuecomment-318665739
    terraform plan -destroy $(for r in `terraform state list | fgrep -v digitalocean_volume.concourse_volume` ; do printf "-target ${r} "; done) -out .destroy.plan

    echo "Destroying everything but the persistent volume"
    echo

    terragrunt apply ".destroy.plan"
}


die() {
    terragrunt destroy
}

ping() {
    echo "pong"
}

# No arguments handle
if [[ $# -eq 0 ]]
then
    echo 'some message'
    exit 0
fi

# If given parameter isn't a defined function handle
if ! [[ "$1" =~ ^(help|initialise|reinitialise|hibernate|die|ping)$ ]]
then
    echo "Sorrjan, but command '$1' not found."
    help
else
    eval $1
fi
