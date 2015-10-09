Vagrant & Ansible 環境構築
======

## はじめに
まだ妄言がほとんどです。

## Vagrant 用意
### パッケージ管理ツール
* `ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"`
* `@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin`

### VirtualBox(5.0.6)
* `brew cask install virtualbox`
* `choco install -y virtualbox`
* ※自宅の Windows 環境だと何故か `4.2.12` まで落とさないとNGなので手動でインストール  
VirtualBox は基本的に最新版だと動作しないイメージだなぁ...  
ひとまずあとで下を試す(バージョン指定)  
`choco install virtualbox -version 4.2.12`

### Vagrant(1.7.4)
* `brew cask install vagrant`
* `choco install -y vagrant`

### Git(2.6.1)
* `brew install git`
* `choco install -y git`

### MinGW(Windowsのみ)
* 下の方法ではエラーになったので、今は深く掘り下げずに手動インストール

```
choco install -y mingw
choco install -y mingw-get -version 1.0.3

# 環境変数設定
SETX /M PATH "%PATH%;C:\tools\mingw64\bin;"
```

* 手動でインストールした時の参考
* http://web.plus-idea.net/2014/06/mingw-install-2014/
* `SETX /M PATH "%PATH%;C:\MinGW\msys\1.0\bin;"`

## Vagrantセットアップ

最終的に git clone & vagrant up で終わらせるのが狙い

### Mac

```
cd /path/to/vagrant_dir
git clone https://github.com/team-opst-standard/miyata-sandbox.git
cd miyata-sandbox/Vagrant

# provisioning で playbook も実行
vagrant up

# やり直す
vagrant destroy -f
vagrant up
```

### Windows

```
cd /path/to/vagrant_dir
git clone https://github.com/team-opst-standard/miyata-sandbox.git
cd miyata-sandbox/Vagrant
# Vagrantfile を Windows 用に編集する(コメントアウトの切替のみ)
# @NOTEになっている部分を修正
vim Vagrantfile

# provisioning で playbook も実行
vagrant up

# やり直す
vagrant destroy -f
vagrant up
```

## Ansible の設定

### ディレクトリ構造について
基本的に公式のベストプラクティスをそのまま使っている
* http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout

### タスク登録について
各コマンドの書き方は下記URL
* http://www.kyoshida.jp/ansibledoc-ja/list_of_all_modules.html

検索してもこれを紹介しているところがほとんど無く、  
パラメータのキーがなぜそうなっているのかわかりづらかった...  

＼公式ドキュメント万歳 & 翻訳感謝／

### ansible-playbook の前に ansible をやってみる

```
# オプション詳細確認
$ ansible --help

# オプションを設定して実行
$ ansible defaults \
--inventory-file=/path/to/Vagrant/playbook/hosts \
--module-name=yum \
--args="name=* state=latest" \
--private-key=/path/to/Vagrant/.vagrant/machines/default/virtualbox/private_key \
--user=vagrant \
--su-user=root \
--verbose

# hostsに下記設定を記載すればコマンドは少し短くなる
# playbook で実行する場合は playbook/hosts にこう書いたほうがいいのだろうか...?
# ここにベタに書かなくてもいい方法があるはず！
[default]
192.168.33.10 ansible_ssh_private_key_file=/path/to/Vagrant/.vagrant/machines/default/virtualbox/private_key ansible_ssh_user=vagrant

# playbook/hosts に接続用の情報を書いた場合のコマンド
$ ansible defaults -i /path/to/Vagrant/playbook/hosts -m yum -a "name=* state=latest"
```

### 上記ansibleコマンドと同じことをansible-playbookでやってみる

```
# hosts
[default]
192.168.33.10

# development.yml
- hosts: development
  roles:
    - common

# roles/common/tasks/main.yml
- name: update yum modules
  # yum: name=* state=latest とも書ける
  yum:
    name: *
    state: latest
```

当然他にも色々できるのでroleディレクトリ配下参照

## Roles について
タスクはずらずら書くのではなくモジュール化するのが良いとのこと。  
そのモジュールを配置するのが roles ディレクトリ。

@TODO `main.yml` という名前があるくらいだから include して他のファイルも定義できそう？

### 構成例は下記
```
playbook/roles/
└── common               ... モジュール名。playbook に記載する名前そのもの
    ├── handlers         ... @TODO 何に使用するか調査中
    │   └── main.yml
    ├── tasks            ... 実行するタスクを main.yml に記載
    │   └── main.yml
    ├── templates        ... @TODO 調査中。設定ファイルなどをテンプレート化して反映するのに使う
    │   └── main.yml
    └── vars             ... この roles 内で使用するための変数を main.yml に定義
        └── main.yml
```


# 進捗ここまで


## 実行流れ？
playbookディレクトリ直下のsite.ymlがマスターとなって
development.yml, webserver.yml, dbserver.ymlを呼び出す。
これで一気に作れる。

↓動作が怪しい
ローカルの仮想マシンに実行する場合、cloneしたVagrantfileのansible.limitの値を"development"に設定してから実行する。そうすることでhostsをdevelopmentに限定できる。全部やるときは"all"で。

## 参考サイト
* https://1000ch.net/posts/2015/vagrant-ansible.html
* http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout
* http://docs.ansible.com/ansible/list_of_all_modules.html
* https://github.com/ansible/ansible-examples
* http://www.moyashi-koubou.com/blog/vagrant_ansible_windows/
* 日本語: http://www.kyoshida.jp/ansibledoc-ja/



