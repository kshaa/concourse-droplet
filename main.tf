# Use AWS S3 for Terragrunt state
# https://github.com/gruntwork-io/terragrunt/issues/212
terraform {
  backend "s3" {}
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Declare access key
resource "digitalocean_ssh_key" "kshaa_access_key" {
  name       = "Official Kshaa key"
  public_key = "${file("${path.module}/id_rsa.pub")}"
}

# Create a web server
resource "digitalocean_droplet" "concourse_droplet" {
  image  = "ubuntu-18-04-x64"
  name   = "concourse-london"
  region = "lon1"
  size   = "s-1vcpu-1gb"

  ssh_keys = ["${digitalocean_ssh_key.kshaa_access_key.fingerprint}"]

  # Droplet itself is in a private network
  # See the "Floating IP" below for public access
  ipv6               = true
  private_networking = true
}

# Add public access to droplet
resource "digitalocean_floating_ip" "concourse_droplet_ip" {
  droplet_id = "${digitalocean_droplet.concourse_droplet.id}"
  region     = "${digitalocean_droplet.concourse_droplet.region}"
}

# Return the public (floatin) droplet IP
output "droplet_ip" {
  value = "${digitalocean_floating_ip.concourse_droplet_ip.ip_address}"
}

