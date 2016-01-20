#!/bin/sh
## for Mac
#
#echo "SHELL TASK [Install Homebrew] **************************************************"
#ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#
#echo "SHELL TASK [Install Cask] ******************************************************"
#brew install caskroom/cask/brew-cask
#
#echo "SHELL TASK [Install VirtualBox] ************************************************"
#brew cask install virtualbox
#
#echo "SHELL TASK [Install Vagrant] ***************************************************"
#brew cask install vagrant
#
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

echo "SHELL TASK [modificate Log file] ***********************************************"
LF=$(printf '\\\012_')
LF=${LF%_}
sed -i".org" -e 's/\\n/'"$LF"'/g' -e 's/\\r//g' -e 's/\\t/    /g' playbook/log/provisioning.log
