bash 'install latest docker engine' do
  code <<-BASH
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    REPO_URL='https://download.docker.com/linux/ubuntu'
    curl -fsSL "$REPO_URL/gpg" | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] $REPO_URL $(lsb_release -cs) stable"

    apt-get update
    apt-get install -y docker-ce
  BASH

  creates '/usr/bin/docker'
end
