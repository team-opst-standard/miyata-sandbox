Vagrant & Ansible 環境構築
======

## はじめに
まだ妄言がほとんどです。

## 各種ツールのインストール
### パッケージ管理ツール

#### Mac
* <a href="http://brew.sh/index_ja.html" target="_blank">Homebrew</a>
```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

* <a href="http://caskroom.io/" target="_blank">Homebrew Cask</a>
```bash
brew install caskroom/cask/brew-cask
```

#### Windows
* <a href="https://chocolatey.org/" target="_blank">Chocolatey</a>
```bash
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
```

### <a href="https://www.virtualbox.org/" target="_blank">VirtualBox(5.0.6)</a>
#### Mac
```bash
brew cask install virtualbox
```

#### Windows
```bash
choco install -y virtualbox
```

* ※自宅の Windows 環境だと何故か `4.2.12` まで落とさないとNGなので手動でインストール  
VirtualBox は基本的に最新版だと動作しないイメージだなぁ...  
ということでバージョンを指定  
```bash
choco install virtualbox -version 4.2.12
```

### <a href="https://www.vagrantup.com/" target="_blank">Vagrant(1.7.4)</a>
#### Mac
```bash
brew cask install vagrant
```

#### Windows
```bash
choco install -y vagrant
```

### <a href="https://git-scm.com/" target="_blank">Git(2.6.1)</a>
#### Mac
```bash
brew install git
```

#### Windows
```bash
choco install -y git
```

### <a href="http://www.ansible.com/" target="_blank">Ansible(Macのみ)</a>
* ホストOSがWindowsの場合は仮想マシン内にインストールするため、ここではMacのみ。
```bash
brew install ansible
```

### <a href="http://www.mingw.org/" target="_blank">MinGW</a>(Windows)
* 下の方法ではエラーになったので、今は深く掘り下げずに手動インストール  
```bash
choco install -y mingw
choco install -y mingw-get -version 1.0.3
```

* 環境変数設定  
```bash
SETX /M PATH "%PATH%;C:\tools\mingw64\bin;"
```

* <a href="http://web.plus-idea.net/2014/06/mingw-install-2014/" target="_blank">手動でインストールした時の参考</a>
```bash
SETX /M PATH "%PATH%;C:\MinGW\msys\1.0\bin;"
```

## Vagrantセットアップ

基本的に git clone & vagrant up で終わり

```bash
cd /path/to/vagrant_dir
git clone https://github.com/team-opst-standard/miyata-sandbox.git
cd miyata-sandbox/Vagrant

# Vagrantfile を Windows or Mac 用に編集する(コメントアウトの切替のみ)
# @NOTEになっている部分を修正
vim Vagrantfile

# provisioning で playbook も実行
vagrant up

# やり直す
vagrant destroy -f
vagrant up
```

## Ansible のシンプルな設定例

### ディレクトリ構造について
公式のベストプラクティスをそのまま使う
* http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout

```bash
playbook/
├── development.yml        ... playbook 本体
├── hosts                  ... 対象のサーバ情報を記載するファイル
└── roles/                 ... モジュール化したタスクを登録するディレクトリ(後述)
     └── common/
         └── tasks/
              └── main.yml
```

### タスクの書き方について
各コマンドの書き方は下記URL
* http://www.kyoshida.jp/ansibledoc-ja/list_of_all_modules.html

検索してもこれを紹介しているところがほとんど無く、  
パラメータのキーがなぜそうなっているのかわかりづらかった...  
（`name` はわかるけど `yum`, `name`, `state` あたりはどこから来たんだ状態）

＼公式ドキュメント万歳 & 翻訳感謝／

### ansible-playbook の前に ansible をやってみる

```bash
# playbook/hosts を Vagrant の IP に向ける
[default]
192.168.33.10

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

# playbook/hosts に下記設定を記載すればコマンドはその分短くなる
[default]
192.168.33.10 ansible_ssh_private_key_file=/path/to/Vagrant/.vagrant/machines/default/virtualbox/private_key ansible_ssh_user=vagrant

# playbook/hosts に接続用の情報を書いた場合のコマンド
$ ansible defaults -i /path/to/Vagrant/playbook/hosts -m yum -a "name=* state=latest"
```

### 上記ansibleコマンドと同じことを ansible-playbook でやってみる

```bash
# playbook/hosts
[development]
192.168.33.10

# playbook/development.yml
- hosts: development
  user: vagrant
  sudo: yes
  roles:
    - common

# playbook/roles/common/tasks/main.yml
- name: update yum modules
  # yum: "name=* state=latest" とも書ける
  yum:
    name: "*"
    state: latest

$ ansible-playbook /path/to/development.yml -i /path/to/hosts
```

当然他にも色々できるので `roles` ディレクトリにどんどん追加していく

## Roles について
タスクはずらずら書くのではなくモジュール化するのが良いとのこと。  
そのモジュールを配置するのが `roles` ディレクトリ。

@TODO `main.yml` という名前があるくらいだから include して他のファイルも定義できそう？

### 構成例は下記

```bash
playbook/roles/
└── common               ... モジュール名。playbook に記載する名前そのもの
    ├── tasks            ... 実行するタスクを main.yml に記載
    │   └── main.yml
    ├── handlers         ... @TODO 調査中
    │   └── main.yml
    ├── templates        ... @TODO 調査中。設定ファイルなどをテンプレート化して反映するのに使う
    │   └── main.yml
    ├── files            ... @TODO 調査中
    │   ├── hoge.txt
    │   └── fuga.sh
    ├── vars             ... この roles 内で使用するための変数を main.yml に定義
    │   └── main.yml
    ├── defaults         ... @TODO 調査中
    │   └── main.yml
    └── meta             ... @TODO 調査中
        └── main.yml
```


# 進捗ここまで

これから書くこと
* このリポジトリの設定ファイルに関する情報(`vagrant up` で何が起こるのか)
* Windows版で使用するfor_windows_host.shの説明

これからやること
* playbook の roles 内をどんどん増やす


Ansibleの設定一覧
* ansible 実行ディレクトリにansible.cfgをおいておけばそれが反映される  
`~/.ansible.cfg` でもいいらしいがソース管理をするなら不便
* https://github.com/ansible/ansible/blob/devel/examples/ansible.cfg

## 参考サイト
* https://1000ch.net/posts/2015/vagrant-ansible.html
* http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout
* http://docs.ansible.com/ansible/list_of_all_modules.html
* https://github.com/ansible/ansible-examples
* http://www.moyashi-koubou.com/blog/vagrant_ansible_windows/
* 日本語: http://www.kyoshida.jp/ansibledoc-ja/
* http://keyamb.hatenablog.com/archive/category/Ansible
