Vagrant & Ansible 環境構築
======

## はじめに
まだ妄言がほとんどです。

## 各種ツールのインストール
### 01. パッケージ管理ツール

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

### 02. <a href="https://www.virtualbox.org/" target="_blank">VirtualBox(5.0.6)</a>
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

### 03. <a href="https://www.vagrantup.com/" target="_blank">Vagrant(1.7.4)</a>
#### Mac
```bash
brew cask install vagrant
```

#### Windows
```bash
choco install -y vagrant
```

### 04. <a href="https://git-scm.com/" target="_blank">Git(2.6.1)</a>
#### Mac
```bash
brew install git
```

#### Windows
```bash
choco install -y git
```

### 05. <a href="http://www.ansible.com/" target="_blank">Ansible</a>(Macのみ)
* ホストOSがWindowsの場合は仮想マシン内にインストールするため、ここではMacのみ。
```bash
brew install ansible
```

### 06. <a href="http://www.mingw.org/" target="_blank">MinGW</a>(Windowsのみ)
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
cd miyata-sandbox/vagrant

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
* ※Windowsではできませんのでスルーしてください
* ※絶対パスで書いていないものはリポジトリのルートディレクトリからの相対

### ディレクトリ構造について
公式のベストプラクティスをそのまま使う
* <a href="http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout" target="_blank">Best Practices &mdash; Ansible Documentation</a>

```bash
sample/vagrant/playbook/
├── development.yml        ... playbook 本体
├── hosts                  ... 対象のサーバ情報を記載するファイル
└── roles/                 ... モジュール化したタスクを登録するディレクトリ(「Roles-について」参照)
     └── common/
         └── tasks/
              └── main.yml
```

### タスクの書き方について
各コマンドの書き方は下記URL
* <a href="http://docs.ansible.com/ansible/list_of_all_modules.html" target="_blank">All Modules &mdash; Ansible Documentation</a>

検索してもこれを紹介しているところがほとんど無く、  
パラメータのキーがなぜそうなっているのかわかりづらかった...  
（`name` はわかるけど `yum`, `name`, `state` あたりはどこから来たんだ状態）  
~~最低でもまずドキュメントは読もう~~

＼公式ドキュメント万歳 & 翻訳感謝／

### ansible-playbook の前に ansible を試す
* `yum upgrade` を実行してみます

#### sample/vagrant/playbook/hosts を Vagrant の IP に向ける
```bash
[default]
192.168.33.10
```

#### オプション詳細確認
```bash
ansible --help
```

#### オプションを設定して実行
```bash
ansible defaults \
--inventory-file=sample/vagrant/playbook/hosts \
--module-name=yum \
--args="name=* state=latest" \
--private-key=/path/to/Vagrant/.vagrant/machines/default/virtualbox/private_key \
--user=vagrant \
--su-user=root \
--verbose
````

### 上記コマンドの変化形
playbook/hosts に下記設定を記載すればコマンドはその分短くなる
```bash
[development]
192.168.33.10 ansible_ssh_private_key_file=sample/vagrant/.vagrant/machines/default/virtualbox/private_key ansible_ssh_user=vagrant
```

#### 実行
ややコマンドがすっきりする
```bash
ansible defaults \
-i sample/vagrant/playbook/hosts \
-m yum \
-a "name=* state=latest"
```

### 同じことを ansible-playbook で試す
#### sample/vagrant/playbook/hosts
```bash
[development]
192.168.33.10 ansible_ssh_private_key_file=sample/vagrant/.vagrant/machines/default/virtualbox/private_key ansible_ssh_user=vagrant
```

#### sample/vagrant/playbook/development.yml
* roles については[後述](#roles-について)

```yml
- hosts: development
  user: vagrant
  sudo: yes
  roles:
    - common
```

#### sample/vagrant/playbook/roles/common/tasks/main.yml
```yml
- name: update yum modules
  # yum: "name=* state=latest" とも書ける
  yum:
    name: "*"
    state: latest
```

### playbook と hosts を指定して実行
```bash
ansible-playbook \
sample/vagrant/playbook/development.yml \
-i sample/vagrant/playbook/hosts
```

## Roles について
playbook のタスクはずらずら書くのではなくモジュール化するのが良いとのことで、
そのモジュールを配置するのが `roles` ディレクトリ。
色々できるので `roles` ディレクトリにどんどん追加していくことで環境構築が充実する。

@TODO `main.yml` という名前があるくらいだから include して他のファイルも定義できそう？

### 構成例は下記

```bash
playbook/roles/
└── common               ... モジュール名。playbook に記載する名前そのもの
    ├── tasks            ... 実行するタスクを main.yml に記載
    │   └── main.yml
    ├── handlers         ... タスクの実行後に実行されるタスク。 tasks/main.yml に notify を設定する
    │   └── main.yml
    ├── templates        ... 設定ファイルなどをテンプレート化して反映するために使う
    │   └── main.yml
    ├── files            ... タスクで使用するシェルスクリプトやタスク内でコピーするファイルの配置場所
    │   ├── hoge.txt
    │   └── fuga.sh
    ├── vars             ... この roles 内で使用するための変数を main.yml に定義
    │   └── main.yml
    ├── defaults         ... roles 内で使用する変数を main.yml に定義。 vars/main.yml よりも優先度低。
    │   └── main.yml
    └── meta             ... @TODO 調査中（role dependencies）
        └── main.yml
```

### roles の各ディレクトリにおける役割
@TODO

## ansible を自分自身のマシンに実行する
ansible は基本的にSSHでリモートマシンの操作を行うが、
ローカルのマシンでは `connection` のオプションを設定することでSSH接続を行わずに実行できる

<a href="http://docs.ansible.com/ansible/playbooks_delegation.html#local-playbooks" target="_blank">Delegation, Rolling Updates, and Local Actions &mdash; Ansible Documentation</a>

### 上の例をローカルで実行できるように
* ※例なので Vagrant の仮想マシン内で実行してます
* `connection` のオプションはコマンドラインで指定することも可能(`--connection=local`)

#### sample/playbook/loal.yml
```yml
- hosts: 127.0.0.1
  connection: local
  user: vagrant
  sudo: yes
  roles:
    - common
```

#### コマンド実行
```bash
# yum install ansible
ansible-playbook \
/vagrant/playbook/local.yml \
--verbose
```

## ansible の動作設定のカスタマイズ
Ansibleの動作設定は `ansible.cfg` ファイルを所定の場所配置することでカスタマイズできる

### 設定ファイル配置場所
ソース管理をするならコマンド実行ディレクトリの方が何かと便利な印象
* ホームディレクトリ直下(`~/ansible.cfg`)
* ansible コマンド実行ディレクトリ

### 設定項目一覧
* <a href="http://docs.ansible.com/ansible/intro_configuration.html" target="_blank">Configuration file &mdash; Ansible Documentation</a>

### 設定サンプル
* <a href="https://github.com/ansible/ansible/blob/devel/examples/ansible.cfg" target="_blank">ansible/ansible.cfg at devel · ansible/ansible</a>

## 参考サイト
* https://1000ch.net/posts/2015/vagrant-ansible.html
* http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout
* http://docs.ansible.com/ansible/list_of_all_modules.html
* https://github.com/ansible/ansible-examples
* http://www.moyashi-koubou.com/blog/vagrant_ansible_windows/
* http://www.kyoshida.jp/ansibledoc-ja/
* http://keyamb.hatenablog.com/archive/category/Ansible
* http://tdoc.info/blog/2013/04/20/ansible.html
