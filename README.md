# Concourse on DigitalOcean
Infrastructure, deployment and [Docker](https://www.docker.com/) to host [Concourse](https://concourse-ci.org/) in a [DigitalOcean](https://www.digitalocean.com/) droplet.

This is basically a combination of the official [Concourse docker repo](https://github.com/concourse/concourse-docker/) and deployment code from [siers](https://github.com/siers) folkdance repo.

# TL;DR Execution
## Infrastructure
DigitalOcean infrastructure provisioned by [Terraform](https://www.terraform.io/) `/deploy/terraform`

Infrastructure state locked by [Terragrunt](https://github.com/gruntwork-io/terragrunt)

Includes:
* Droplet (host) (cheapest there is)
* Floating IP (static IP)
* Persistent storage (Concourse storage, in case we want to destroy the infrastructure, but hold the data)
* SSH keys (to connect to the host if necessary for some reason)
* [Cloud init](https://cloud-init.io/) scripts (to automatically deploy concourse when infrastructure is initialised) `/deploy/terraform/init-cloud`

## Deployment
This is slightly verbose, because I didn't understand the chef part, so I'm documenting it for myself

1. Cloud init script uploads this repo to the droplet and starts [Chef](https://www.chef.io/chef/) `/deploy/chef/init`
2. Chef 'main' role is run on the droplet `/deploy/chef/roles/main.json`
3. Chef 'main' role runs 'app' recipe on droplet `/deploy/chef/app-cookbook/recipes/app.rb`
4. 'app' (boilerplate) sets up persistent storage on `/mnt/persistent` `/deploy/chef/app-cookbook/recipes/persist.rb`
5. 'app' (boilerplate) installs some packages `/deploy/chef/app-cookbook/recipes/packages.rb`
5. 'app' (boilerplate) sets up docker engine & docker compose `/deploy/chef/app-cookbook/recipes/docker.rb` & `supermarket.chef.io/cookbooks/docker_compose`
6. 'app' triggers `/generate-keys.sh` for generating Concourse container communication SSH keys
6. 'app' initialises Concourse containers `/docker-compose.yml` w/ credentials from `/secrets.env`
