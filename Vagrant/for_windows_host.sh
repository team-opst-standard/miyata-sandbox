#!/bin/sh

# for_windows_host.sh
$GROUP=$1

# Ansible インストール
yum install -y ansible

# Ansible 実行
ansible-playbook /vagrant/playbook/site.yml -i /vagrant/playbook/hosts $GROUP
