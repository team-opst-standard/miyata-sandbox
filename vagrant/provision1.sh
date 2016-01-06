#!/bin/sh

cd /vagrant

# install Ansible
echo "[command]sudo yum install -y ansible"
sudo yum install -y ansible

# execute Ansible
# echo "[command]ansible-playbook /vagrant/playbook/provision1.yml --verbose --connection=local"
# ansible-playbook /vagrant/playbook/provision1.yml --verbose --connection=local
