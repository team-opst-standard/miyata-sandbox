#!/bin/sh

cd /vagrant

# execute Ansible
echo "[command]ansible-playbook /vagrant/playbook/provision1.yml --verbose --connection=local"
ansible-playbook /vagrant/playbook/provision1.yml --verbose --connection=local
