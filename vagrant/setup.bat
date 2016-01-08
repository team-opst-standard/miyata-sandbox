@echo off

echo "SHELL TASK [Vagrant up] ********************************************************"
vagrant up --no-provision

echo "SHELL TASK [Vagrant provision (1)] *********************************************"
vagrant provision --provision-with provision1

echo "SHELL TASK [Vagrant Reload] ****************************************************"
vagrant reload

echo "SHELL TASK [Vagrant provision (2)] *********************************************"
vagrant provision --provision-with provision2
