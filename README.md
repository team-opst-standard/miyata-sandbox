Vagrant & Ansible を用いた環境構築
======

## はじめに
* LAMP環境を構築(CentO6.5 + Apache2.2 + MySQL5.5 + PHP5.5)
* ローカル開発環境を構築する為のもので、それ以外の環境は対象外
* VagrantとAnsibleに最低限知識がある人向け
* ミドルウェアは基本的にyumでインストールしているのでその辺りの知識がある人向け
* Java8なども導入可能(オマケ)

## ディレクトリ構造
* 公式のベストプラクティスをそのまま使用  
<a href="http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout" target="_blank">Best Practices &mdash; Ansible Documentation</a>

```bash
miyata-sandbox
├── README.md
└── vagrant
    ├── Vagrantfile
    ├── ansible.cfg
    ├── create_roles.sh     ... rolesの雛形を作る
    ├── playbook
    │   ├── group_vars
    │   ├── host_vars
    │   ├── inventories
    │   ├── library
    │   ├── log            ... playbookのログ配置場所
    │   ├── provision1.yml ... provision1.shで呼ばれるplaybook
    │   └── roles
    │       ├── common     ... ユーザー作成
    │       ├── httpd22    ... yumによるhttpd2.2インストール, httpd.conf適用, サービス起動
    │       ├── jdk18      ... JDK1.8をrpmパッケージからインストール, PATH追加用スクリプト配置
    │       ├── maven32    ... Maven3.2のアーカイブをダウンロードして所定の場所に配置, PATH追加用スクリプト配置
    │       ├── memcached  ... yumによるMemcached1.4インストール, 起動スクリプト適用, サービス起動
    │       ├── mysql55    ... yumによるMySQL5.6インストール, my.cnf適用, サンプルDBのダンプインポート, サービス起動
    │       ├── mysql56    ... yumによるMySQL5.6インストール, my.cnf適用, サンプルDBのダンプインポート, サービス起動
    │       ├── nginx18    ... yumによるNginx1.8インストール, nginx.conf適用, サービス起動
    │       ├── php53      ... yumによるPHP5.3インストール, php.ini適用
    │       ├── php55      ... yumによるPHP5.5インストール, php.ini適用
    │       ├── php56      ... yumによるPHP5.6インストール, php.ini適用
    │       └── yum        ... リポジトリ追加, 最新化, 諸ツールインストール
    ├── provision1.sh       ... "provision1.sh, provision2.sh, ..." は再起動が必要な場合に分ける想定
    ├── provision2.sh
    ├── setup.bat           ... vagrantの起動とprovisioningを制御
    └── setup.sh
```

## ファイルの説明

@TODO


## 準備: 各種ツールのインストール
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

* 何故か `4.2.12` まで落とさないとNGなので手動でインストール  
おそらくその時のマシンの状態に依存するのだろうが、  
VirtualBox は基本的に最新版だと動作しないイメージ...  

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

### 05. <a href="http://www.mingw.org/" target="_blank">MinGW</a>(Windowsのみ)
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

## 環境構築

* 基本的に git clone & setup.bat 実行で終了させる想定

### リポジトリをクローン

```bash
cd /path/to/vagrant_dir
git clone https://github.com/team-opst-standard/miyata-sandbox.git
cd miyata-sandbox/vagrant
```

### インストールするものを選ぶ

* `playbook/provision1.yml` を編集して実行するrolesを設定

### Vagrantセットアップ

```bash
# setup.bat(Macならsetup.sh)を実行
setup.bat

# やり直す場合は下記実行後にもう一度setup.batを実行
vagrant destroy -f
```

以上で環境構築は終了。


## 環境の確認

### Vagrant 起動
* 上記環境構築の後であればVagrantは再起動済みの為、下記手順は不要。  
下記は次回以降のVagrant起動コマンド。

```
# vagrant up 以外のコマンドも原則下記ディレクトリに移動してから実行
cd /path/to/vagrant_dir/miyata-sandbox/vagrant
vagrant up
```

### Vagrant へのSSH接続確認

```
vagrant ssh
```

### Apache HTTPD 確認
* http://192.168.33.10 にアクセスして初期画面が表示されること
* WindowsだとAnsibleからはhostsを触れないのでIPでの確認となる

### MySQL 確認
* MySQLに接続してサンプルのDBが確認できること

```
mysql -uroot

show databases;
use vagrant_example;
show tables;
select * from test;
```

### PHP 確認
* `php -v` コマンドでバージョンを確認
* http://192.168.33.10/phpinfo.php にアクセスして `phpinfo();` の結果が表示されること
* http://192.168.33.10/mysql.php にアクセスして vagrant_example.test のレコードが表示されること
