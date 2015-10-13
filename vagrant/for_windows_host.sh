#!/bin/sh

# for_windows_host.sh
GROUP="windows_host"
echo "Execution Start Ansible GROUP=$GROUP"

# install Ansible
echo "[command]sudo yum install -y ansible"
sudo yum install -y ansible

# execute Ansible
cat << EOS
[command]ansible-playbook /vagrant/playbook/site.yml 
-i /vagrant/playbook/inventories/development 
--connection=local 
EOS

ansible-playbook /vagrant/playbook/site.yml \
-i /vagrant/playbook/inventories/development \
--connection=local \
--verbose

echo "End of execution Ansible GROUP=$GROUP"
