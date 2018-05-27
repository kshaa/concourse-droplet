# Concourse on DigitalOcean

# Not finished, read Todo below

Infrastructure, deployment and [Docker](https://www.docker.com/) to host [Concourse](https://concourse-ci.org/) in a [DigitalOcean](https://www.digitalocean.com/) droplet.

This is basically a combination of the official [Concourse docker repo](https://github.com/concourse/concourse-docker/) and deployment code from [siers](https://github.com/siers) folkdance repo.

# Quick-start 
#### Configure the following:
* [AWS CLI + credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* Terraform
* Terragrunt

#### Update/Create the following files (samples provided):
* `/deploy/terraform/variable.tf` (DigitalOcean token, etc)
* `/deploy/terraform/terraform.tfvars` (Infrastructure current state locking)
* `/deploy/terraform/id_rsa.pub` (Public SSH key to connect to droplet)
* `/deploy/terraform/secrets.env` (Concourse docker compose secrets) (This will be copied on the droplet)

#### Run:
1. `terragrunt apply`
2. Fix errors because probably something failed the first time
3. Repeat step 1. and 2. until errors are gone

#### Use:

Terraform returned an IP of the Concourse droplet, you now have a working
Concourse server, read some [Concourse documentations](http://concoursetutorial.com/) and have fun.

# After quick-starting
#### Kill: (This will destroy all data)
1. `terragrunt destroy`

#### Hibernate: (This will destroy all but persistent storage)
1. `./helper.sh hibernate`
2. Hope it works
3. If it didn't work, read helper.sh and fix it
4. When you want it back run `terragrunt apply`
5. Hope it works

Note: _Hope is your friend in this repo_

# Deployment flow
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

# Todo
* Set up a domain for the droplet
* Set up a way for the `secrets.env` to end up in the droplet
* Fix sometimes `generate-keys.sh` needs re-running
* Set up the Concourse Postgresql container to use the persistent volume
* Move docker-ce from 'test' version to 'stable', when it's released in `/deploy/chef/app-cookbook/recipes/docker.rb`
