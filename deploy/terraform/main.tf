# Use AWS S3 for Terragrunt state
# https://github.com/gruntwork-io/terragrunt/issues/212
terraform {
  backend "s3" {}
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Web server Concourse
resource "digitalocean_droplet" "concourse_droplet" {
  image  = "ubuntu-18-04-x64"
  name   = "concourse-london"
  region = "${var.region}"
  size   = "${var.droplet_size}"
  ssh_keys = ["${digitalocean_ssh_key.access_key.fingerprint}"]

  user_data = "${data.template_file.cloud_init.rendered}"
  volume_ids = ["${digitalocean_volume.concourse_volume.id}"]

  # Droplet itself is in a private network
  # See the "Floating IP" below for public access
  ipv6               = true
  private_networking = true
}

# Persistent volume
resource "digitalocean_volume" "concourse_volume" {
  region      = "${var.region}"
  name        = "persist" // This name is hardcoded in chef recipes
  size        = "${var.volume_size}"
  description = "persistent volume (db, docker images, etc.)"
}

# Access key
resource "digitalocean_ssh_key" "access_key" {
  name       = "SSH Access key"
  public_key = "${file("${path.module}/id_rsa.pub")}"
}

# Floating Ip
resource "digitalocean_floating_ip" "concourse_droplet_ip" {
  droplet_id = "${digitalocean_droplet.concourse_droplet.id}"
  region     = "${digitalocean_droplet.concourse_droplet.region}"
}

# Domain setup
resource "digitalocean_domain" "concourse_droplet_domain" {
  // Terraform has a weird way to handle conditional resources - count
  count = "${var.domain_exists}"

  name = "${var.domain_name}"
  ip_address = "${digitalocean_floating_ip.concourse_droplet_ip.ip_address}"
}

# Initialisation script
data "template_file" "cloud_init" {
  template = "${file("${path.module}/init-cloud/cloud-init-chef-bootstrap.yaml")}"

  vars {
    source = "${var.source}"
    // This injects the secrets.env file with indentation of six spaces, because
    // in the cloud init, the yaml syntax there requires an indentation
    // see ./init-cloud/cloud-init-chef-bootstrap.yaml :: ${secrets}
    secrets = "${replace(file("${path.module}/secrets.env"), "/(?m)^/", "      ")}"
  }
}

# Return the public (floating) droplet IP
output "droplet_ip" {
  value = "${digitalocean_floating_ip.concourse_droplet_ip.ip_address}"
}
