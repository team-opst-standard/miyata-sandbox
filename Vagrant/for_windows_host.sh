#!/bin/sh

# for_windows_host.sh
GROUP="windows_host"
echo "Execution Start Ansible GROUP=$GROUP"

echo "[command]PRIVATE_KEY_FILE=/vagrant/.vagrant/machines/default/virtualbox/private_key"
PRIVATE_KEY_FILE="/vagrant/.vagrant/machines/default/virtualbox/private_key"

echo "[command]export ANSIBLE_HOST_KEY_CHECKING=False"
export ANSIBLE_HOST_KEY_CHECKING=False

# install Ansible
echo "[command]sudo yum install -y ansible"
sudo yum install -y ansible

# execute Ansible
cat << EOS
[command]ansible-playbook /vagrant/playbook/site.yml 
-i /vagrant/playbook/inventories/development 
--connection=local 
EOS
# --private-key=$PRIVATE_KEY_FILE 
# --extra-vars="provision_target=$GROUP" 
# --verbose

ansible-playbook /vagrant/playbook/site.yml \
-i /vagrant/playbook/inventories/development \
--connection=local \
--verbose

# --private-key=$PRIVATE_KEY_FILE \
# --extra-vars="provision_target=$GROUP" \

echo "End of execution Ansible GROUP=$GROUP"
