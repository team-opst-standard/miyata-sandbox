#!/bin/sh

# for_windows_host.sh

# install Ansible
echo "[command]sudo yum install -y ansible"
sudo yum install -y ansible

# execute Ansible
echo "[command]ansible-playbook /vagrant/playbook/site.yml --connection=local --extra-vars=\"provision_target=localhost\""

ansible-playbook /vagrant/playbook/site.yml \
--connection=local \
--extra-vars="provision_target=localhost" \
--verbose
