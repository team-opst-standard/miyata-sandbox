Vagrant, Ansibleを使ったLAMP環境構築(簡易)
=======

## まずインストール
* パッケージ管理
    * ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    * @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
* VirtualBox
    * brew cask install virtualbox
    * choco install virtualbox
* Vagrant
    * brew cask install vagrant
    * choco install vagrant

## VirtualBox
### CentOS6.6 インストール
* http://ftp.jaist.ac.jp/pub/Linux/CentOS/6.6/isos/x86_64/CentOS-6.6-x86_64-bin-DVD1.iso
* http://ftp.jaist.ac.jp/pub/Linux/CentOS/6.6/isos/x86_64/CentOS-6.6-x86_64-bin-DVD2.iso

### インストール時の設定
* root:vagrant
* vagrant:vagrant

### インストール後
* groupadd admin
* usermod -G admin -a vagrant
* /usr/sbin/visudo

```bash
# 追記
Defaults env_keep += "SSH_AUTH_SOCK"
vagrant ALL=(ALL) ALL
%admin ALL=(ALL) NOPASSWD:ALL

# 修正
# Defaults requiretty
Defaults !requiretty
```

### VirtualBox Guest Additionsインストール
* yum -y install gcc kernel-devel-2.6.32-504.el6.x86_64
* メニューからGuest Additionsのディスクマウント
* /media/VBOXADDITIONS_4.3.28_100309/VBoxLinuxAdditions.run
* VBoxControl --version
* VBoxService --version
* umount /media/VBOXADDITIONS_4.3.28_100309/

### SSH接続できるように
* sudo su vagrant
* mkdir ~/.ssh
* curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub > ~/.ssh/authorized_keys
* chmod 0644 ~/.ssh/authorized_keys
* shutdown -h now

## VagrantでBox作成~起動
* cd /Users/username/VirtualBox\ VMs/vagrant-ansible/
* vagrant package --base vagrant-ansible --output vagrant-ansible.box
* mkdir ~/Vagrant
* cd ~/Vagrant
* mv /Users/username/VirtualBox\ VMs/vagrant-ansible/vagrant-ansible.box ~/Vagrant/vagrant-ansible.box
* vagrant init
* vagrant box add vagrant-ansible vagrant-ansible.box
* Vagrantfile 編集

```
# config.vm.box = "base"
config.vm.box = "vagrant-ansible.box"
```

* vagrant up
* vagrant ssh

※ここまでは誰かが一度だけ作ればよい

## ここまで参考
* http://qiita.com/t_oginogin/items/e9d2efff211b4ae064df


## Ansible

### インストール
* rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
* yum install ansible

### playbook作成
* vim lamp-playbook.yml
    * 参考サイトの内容をひとまずコピペ。色々不足しているので意味などは後ほど
* ansible-playbook lamp-playbook.yml

### 確認
* php   --version
* mysql --version
* httpd -v

## ここまで参考
* http://liginc.co.jp/web/programming/server/129004

# 課題
* iptablesは手動で接続許可をした
    * -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
* yumで単純に入れるといい加減バージョンが古すぎる
    * phpは5.5, httpdは2.4, MySQLは5.6とか欲しいところ

# 所感
* 今回は自分自身にplaybookを実行したので仮想マシン内部で完結
    * Ansible導入以降はOSに依存せずできそう

* Vagrantの導入完了までが大変
    * VagrantとVirtualboxとCentOSインストールは必要(Ansibleでできるかどうか...)
    * boxファイルは一度自作してそれを使いまわすのが良い  
      配布されているVagrantのboxはどうも信用しにくい...

