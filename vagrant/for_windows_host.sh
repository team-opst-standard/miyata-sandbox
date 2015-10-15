#!/bin/sh

# for_windows_host.sh

# install Ansible
echo "[command]sudo yum install -y ansible"
sudo yum install -y ansible

# execute Ansible
echo "[command]ansible-playbook /vagrant/playbook/site.yml -i /vagrant/playbook/inventories/development --connection=local --extra-vars=\"provision_target=windows_host\""

ansible-playbook /vagrant/playbook/site.yml \
-i /vagrant/playbook/inventories/development \
--connection=local \
--extra-vars="provision_target=windows_host" \
--verbose
