# Develop環境をDockerで動かす方法

Dockerと[direnv](https://github.com/direnv/direnv)が必要なので、事前にインストールを済ませてください。

## 構築手順

`.envrc` に以下の行を追加します。

```bash
export COMPOSE_PROJECT_NAME=bootcamp
export COMPOSE_FILE=.devcontainer/docker-compose.yml:docker-compose.darwin.yml
```

`direnv allow` を実行して`docker-compose` コマンドでコンテナを起動します。

```bash
$ direnv allow
direnv: loading ~/ghq/github.com/fjordllc/bootcamp/.envrc
direnv: export +COMPOSE_FILE +COMPOSE_PROJECT_NAME

$ docker-compose up -d
Creating network "bootcamp_default" with the default driver
Creating volume "bootcamp_postgres-data" with default driver
Creating volume "bootcamp_bundle" with default driver
Creating volume "bootcamp_node_modules" with default driver
Creating volume "bootcamp_rails_cache" with default driver
Creating volume "bootcamp_packs" with default driver
Creating volume "bootcamp_packs_test" with default driver
Creating bootcamp_db_1 ... done
Creating bootcamp_app_1 ... done
```

初期設定を行うため、コンテナ内で `bin/setup` と `bin/rails db:test:prepare` を実行します。

```bash
$ docker-compose exec app bash

root ➜ /workspace (main) $ bin/setup

root ➜ /workspace (main) $ bin/rails db:test:prepare
```

## サーバの起動

コンテナ内で `bin/rails s` を実行してください。

```bash
$ docker-compose exec app bash

root ➜ /workspace (main) $ bin/rails s
=> Booting Puma
=> Rails 6.1.4.1 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 5.5.1 (ruby 2.7.4-p191) ("Zawgyi")
*  Min threads: 5
*  Max threads: 5
*  Environment: development
*          PID: 3496
* Listening on http://0.0.0.0:3000
Use Ctrl-C to stop
```

ブラウザで http://localhost:3000/ を表示できます。

## テストの実行

コンテナ内で `bin/rails test` を実行してください。

```bash
$ docker-compose exec app bash

root ➜ /workspace (main) $ bin/rails test
Running via Spring preloader in process 3527
Run options: --seed 54803

# Running:

...................................................................................................................................................................................................

Finished in 21.972606s, 8.8747 runs/s, 36.1814 assertions/s.
195 runs, 795 assertions, 0 failures, 0 errors, 0 skips
```
