#!/bin/sh

cd /vagrant

# install Ansible
echo "[command]sudo yum install -y ansible"
sudo yum install -y ansible

# playbook for kernel update
echo "[command]ansible-playbook /vagrant/playbook/prepare.yml --verbose --connection=local"
ansible-playbook /vagrant/playbook/prepare.yml --verbose --connection=local
