[![CI](https://github.com/fjordllc/bootcamp/actions/workflows/ci.yml/badge.svg)](https://github.com/fjordllc/bootcamp/actions/workflows/ci.yml)
[![Create a release pull-request](https://github.com/fjordllc/bootcamp/actions/workflows/git-pr-release-action.yml/badge.svg)](https://github.com/fjordllc/bootcamp/actions/workflows/git-pr-release-action.yml)

# Bootcamp

エンジニア向けEラーニングシステム。

## インストールと起動

### 1. 画像処理ライブラリのインストール

wiki 内の[画像処理ライブラリのインストール](https://github.com/fjordllc/bootcamp/wiki/%E7%94%BB%E5%83%8F%E5%87%A6%E7%90%86%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)ページを参照してください。

### 2. セットアップとサーバーの起動

```
$ bin/setup
$ bin/dev 
```

http://localhost:3000/ にアクセス。

## 提出物のAIレビュー支援

提出物の初回提出・本文更新時にバックグラウンドでレビュー支援を生成し、提出物のHTML画面でメンター・管理者だけに表示します。コメント・承認・通知は作成しません。

`ANTHROPIC_API_KEY` を設定してください。モデルは `claude-opus-5-5` が既定で、`PRODUCT_REVIEW_LLM_MODEL` で変更できます。他のAI機能のモデル設定には影響しません。提出本文とプラクティスのタイトル・本文・目標・提出要件・模範解答（存在する場合）をAnthropicへ送信します。

本文や提出先の変更・WIPへの変更時に旧レビューを消します。レビュー本文が保存されたときだけカードを表示します。APIキー未設定・通信エラー・空の応答ではレビューを保存しません。提出物の保存は生成完了を待ちません。生成中に提出本文が変わった場合は、その結果を保存しません。

既存の未確認・非WIPでレビュー本文が空の提出物へのレビュー支援生成は、本番アプリのデプロイ後に自動実行されるデータマイグレーションで一度だけジョブキューへ追加します。既に保存されたレビュー本文は保持します。

AI入出力をHTTPデバッグログに残さないため、稼働環境で `RUBYLLM_DEBUG`・`RUBYLLM_STREAM_DEBUG` は設定しないでください。プロバイダーのエラー本文は画面やジョブログへ出力しません。

## テスト

### Playwright ブラウザーのインストール

system test は Playwright で Chromium を起動します。初回セットアップ時、または Playwright のバージョン更新後にブラウザーをインストールしてください。

```bash
npx playwright install chromium
```

### ヘッドレスブラウザーでテスト

```
$ rails test:all
```

### 普通のブラウザーでテスト

```
$ HEADFUL=1 rails test:all
```

### 並列実行せずにテスト

```
$ PARALLEL_WORKERS=1 rails test:all
```

## Lint

次のコマンドでlintを実行します。

```
$ bin/lint
```

実行されるlint

* Ruby
  * rubocop
  * slim-lint
* JavaScript
  * eslint
  * prettier
* eslintの警告は以下のコマンドで修正されますが、修正されない場合は手動で修正してください。

```shell
$ npx eslint 'app/javascript/**/*.{js,vue,jsx}' --fix
```

* prettierの警告が出ている場合には、以下のコマンドで修正できます。

```shell
$ npx prettier app/javascript/**/*.{js,vue,jsx} --write
```

## Profiler

rack-mini-profilerによりプロファイリングはデフォルトではOFFになっています。ONにする場合は下記のようにサーバーと立ち上げます。

```
$ PROFILE=1 rails server
```

## 環境構築

- [Develop環境でログインする方法](https://github.com/fjordllc/bootcamp/wiki/Develop%E7%92%B0%E5%A2%83%E3%81%A7%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)
- [Develop環境でのメールの確認方法](https://github.com/fjordllc/bootcamp/wiki/Develop%E7%92%B0%E5%A2%83%E3%81%A7%E3%81%AE%E3%83%A1%E3%83%BC%E3%83%AB%E3%81%AE%E7%A2%BA%E8%AA%8D%E6%96%B9%E6%B3%95)
- [nodeのバージョン切り替え](https://github.com/fjordllc/bootcamp/wiki/node%E3%81%AE%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E5%88%87%E3%82%8A%E6%9B%BF%E3%81%88)

## その他

- [Bootcamp Wiki](https://github.com/fjordllc/bootcamp/wiki)
