#!/bin/sh

TARGET=$1

# install Ansible
echo "[command]sudo yum install -y ansible"
sudo yum install -y ansible

# execute Ansible
echo "[command]ansible-playbook /vagrant/playbook/site.yml --connection=local --extra-vars=\"provision_target=$TARGET\""

ansible-playbook /vagrant/playbook/site.yml \
--connection=local \
--extra-vars="provision_target=$TARGET" \
--verbose
