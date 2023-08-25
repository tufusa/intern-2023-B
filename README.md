# インターン2023

これは次の教材で作られたサンプルアプリケーションです。
[*Ruby on Rails チュートリアル*](https://railstutorial.jp/)
（第7版）
[Michael Hartl](https://www.michaelhartl.com/) 著

## ライセンス

[Ruby on Rails チュートリアル](https://railstutorial.jp/)内にある
ソースコードはMITライセンスとBeerwareライセンスのもとで公開されています。
詳細は [LICENSE.md](LICENSE.md) をご覧ください。

## 使い方

### Docker環境で動かす場合

データベースの設定ファイルとしてDocker環境用のものを配置します。

```
$ cp config/database.docker.yml config/database.yml
```

以下のコマンドを実行してイメージを構築します。

```
$ docker-compose build
```

データベースの作成とマイグレーションを行います。

```
$ docker-compose run app bundle exec rails db:create
$ docker-compose run app bundle exec rails db:migrate
```

テストを実行してうまく動作するかどうか確認します。

```
$ docker-compose run app bundle exec rails test
```

テストが無事パスしたら初期データを投入してRailsサーバを立ち上げます。

```
$ docker-compose run app bundle exec rails db:seed
$ docker-compose up
```

### ローカル環境で動かす場合

このアプリケーションを動かす場合は、まずはリポジトリを手元にクローンしてください。
その後、次のコマンドで必要になるライブラリをインストールします。

```
$ sudo apt install sqlite3 libsqlite3-dev
```

次に以下のコマンドで必要になる RubyGems をインストールします。

```
$ gem install bundler -v 2.3.14
$ bundle install --without production
```

データベースの設定ファイルとしてローカル環境用のものを配置します。

```
$ cp config/database.local.yml config/database.yml
```

データベースへのマイグレーションを実行します。

```
$ bin/rails db:migrate
```

最後に、テストを実行してうまく動いているかどうか確認してください。

```
$ bin/rails test
```

テストが無事にパスしたら、Railsサーバーを立ち上げる準備が整っているはずです。

```
$ bin/rails server
```

以下でデータベースへ初期データを投入することができます。

```
$ bin/rails db:seed
```

### 共通

サーバ立ち上げ後は http://localhost:3000/login にアクセスし、以下の情報でログインします。

- Email: example@railstutorial.org
- Password: foobar
