@echo off

echo "SHELL TASK [Vagrant up] ********************************************************"
vagrant up --no-provision

echo "SHELL TASK [Vagrant provision (1)] *********************************************"
vagrant provision --provision-with prepare

echo "SHELL TASK [Vagrant Reload] ****************************************************"
vagrant reload

echo "SHELL TASK [VirtualBox Mount Update] *******************************************"
vagrant ssh -c "sudo /etc/init.d/vboxadd setup"

echo "SHELL TASK [Vagrant provision (2)] *********************************************"
vagrant provision --provision-with provision1

echo "SHELL TASK [Vagrant Reload] ****************************************************"
vagrant reload
