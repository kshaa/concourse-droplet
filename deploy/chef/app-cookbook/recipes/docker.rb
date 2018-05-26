bash 'install latest docker engine' do
  code <<-BASH
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    REPO_URL='https://download.docker.com/linux/ubuntu'
    curl -fsSL "$REPO_URL/gpg" | sudo apt-key add -

    # Docker CE hasn't been released for Ubuntu 18.04 yet
    # https://github.com/docker/for-linux/issues/290#issuecomment-385390118
    # add-apt-repository "deb [arch=amd64] $REPO_URL $(lsb_release -cs) stable"
    add-apt-repository "deb [arch=amd64] $REPO_URL $(lsb_release -cs) test"

    apt-get update
    apt-get install -y docker-ce
  BASH

  creates '/usr/bin/docker'
end
