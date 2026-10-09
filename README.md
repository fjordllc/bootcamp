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

`ProductReviewPracticeContext` は、DBのプラクティスと関連Docからレビュー入力のコンテキストを組み立てるクラスです。

プラクティスの情報はDBのプラクティスと、`Page.for_practice_including_source` で関連付く現在・直近の複製元の公開済みDoc（WIPを除く）から組み立てます。URLの記載は不要で、他のプラクティスやさらに上の複製元までは集めません。DocはID順で最大20件、本文は各20,000文字・合計100,000文字までとし、切り詰め・省略をレビューに伝えます。タイトル・ID・Markdown本文を送り、根拠にはDocのタイトルとIDを使います。コメントやユーザー情報は含めず、受講生のメモを含む参考資料をすべて必須要件として扱わないよう指示します。

HTTP取得は提出本文に直接記載されたMarkdownリンク・自動リンク・画像の先頭10件だけです。相対URLはアプリのホスト・プロトコル設定で解決し、フラグメントを除いて重複をまとめます。教材のDB取得枠とは独立しており、プラクティス・Doc・模範解答内のURLや画像、取得した外部ページのリンクは辿りません。外部資料は既存の公開HTTP(S)取得処理を使い、Cookie・認証情報は送りません。AIには通信ツールを渡しません。

外部取得はURLごとに15秒（DNS・リダイレクトを含む）、レスポンスごとに10MB、リダイレクトは最大5回です。WebページはJavaScriptを実行せず、本文の先頭20,000文字を使います。画像はJPEG・PNG・GIF・WebPを実データで添付し、添付番号を付け、1枚7MB・合計20MB・縦横各8,000pxまでに制限します（MBは1,048,576バイト）。ログインが必要なページ、取得失敗、未対応・破損画像、上限超過は未確認としてレビューに伝えます。これらの制限やJavaScriptで表示される内容はメンターによる確認が必要です。既に保存されているレビューは、この取得機能の追加では自動再生成しません。

公開GitHubのHTTPS PRリンク（`/pull/番号`、`/files`、末尾スラッシュ、直接の`.diff`）は公開の`.diff`を取得します。`blob`リンクは`raw.githubusercontent.com`へ変換し、rawリンクもコードとして読みます。認証付きREST API・トークン・Cookieは使いません。コードの空白・改行・HTML記法を保ち、先頭50,000文字までを使い、切り詰めを明記します。提出元URLと取得先URLを根拠に含めます。PRでは変更箇所とハンク内の文脈のみが確認範囲で、未変更ファイル全体やバイナリの内容は確認できません。差分ではないログイン・エラーページは取得済み扱いにしません。diff内のファイルやリンクを追加取得せず、リポジトリ・tree・issuesのリンクは通常のWebページとして扱います。raw画像には上記の画像制限を適用します。この変更でも保存済みレビューは自動再生成しません。

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
