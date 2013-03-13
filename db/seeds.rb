User.delete_all
Practice.delete_all

User.create!(
  login_name: 'test',
  name: 'hoge',
  email: 'hoge@hoge.com',
  password: 'test',
  password_confirmation: 'test'
)

practice_list = [
  { title: "OS X Lionをクリーンインストールする" },
  { title: "Terminalの基礎を覚える" },
  { title: "PC性能の見方を知る" },
  { title: "Debianをインストールする" },
  { title: "Linuxのファイル操作の基礎を覚える" },
  { title: "aptの基礎を覚える" },
  { title: "viをインストールする" },
  { title: "viのチュートリアルをやる" },
  { title: "sudoをインストールする" },
  { title: "sshdをインストールする" },
  { title: "リモートのサーバーにsshで鍵を使ってログインする" },
  { title: "sshdでパスワード認証を禁止にする" },
  { title: "sshdでrootでのログインを禁止にする" },
  { title: "telnetを使ってget, postを試し、HTTPの基礎を理解する" },
  { title: "HTTPのrequestとresponse、headerとbodyを理解する" },
  { title: "nginxをインストールする" },
  { title: "nginxにネームベースのVirtualHostを使ってサイトを作る" },
  { title: "sslの基礎を理解する" },
  { title: "nginxで自己認証した証明書を使ったssl対応サイトを作る" },
  { title: "sqlの基礎を理解する" },
  { title: "mysqlをインストールする" },
  { title: "mysql, mysqladminコマンドでユーザー、データベース、テーブルを作成する" },
  { title: "rubyをインストールする" },
  { title: "rvmをインストールする" },
  { title: "rvmで複数バージョンのrubyを切り替えれるようにする" },
  { title: "「プログラミング入門 - Rubyを使って」をやる" },
  { title: "「プログラミング入門 - Rubyを使って」をgithubにpushする" },
  { title: "「プログラミング入門 - Rubyを使って」のテストをrspecで書く" },
  { title: "rubygemsの基礎を理解する" },
  { title: "gemコマンドを使ってgemのインストール、更新、削除をする" },
  { title: "rakeの基礎を理解する" },
  { title: "rakeでCプログラムをコンパイルするRakefileを書く" },
  { title: "Getting Started with RailsにしたがってRailsアプリを作る" },
  { title: "ActionControllerを理解する" },
  { title: "ActionViewを理解する" },
  { title: "ActiveRecordを理解する" },
  { title: "ActiveSupportを理解する" },
  { title: "Railsのroutesを理解する" },
  { title: "Railsのi18nの基礎を理解する" },
  { title: "sorceryを使ってユーザー認証を作る" },
  { title: "sorceryを使ってTwitter認証を作る" },
  { title: "exception_notificationを使ってエラーのメール通知機能を作る" },
  { title: "paperclipを使って画像アップロード機能を作る" },
  { title: "TDDの基礎を理解する" },
  { title: "unittestの基礎を理解する" },
  { title: "rspecを使ってRailsアプリのテストを書く" },
  { title: "capybaraを使ってrequest specを書く" },
  { title: "Try Gitをやる" },
  { title: "unicornを使ってrailsアプリを動かす" },
  { title: "capistranoを使ってrailsアプリをデプロイする" },
  { title: "capistrano-extを使ってstaging環境にアプリをデプロイする" }
]

Practice.create!(practice_list)
