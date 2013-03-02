# encoding: utf-8
class InsertSeedToPractices < ActiveRecord::Migration
  def up
    Practice.create!(title: "OS X Lionをクリーンインストールする")
    Practice.create!(title: "Terminalの基礎を覚える")
    Practice.create!(title: "PC性能の見方を知る")
    Practice.create!(title: "Debianをインストールする")
    Practice.create!(title: "Linuxのファイル操作の基礎を覚える")
    Practice.create!(title: "aptの基礎を覚える")
    Practice.create!(title: "viをインストールする")
    Practice.create!(title: "viのチュートリアルをやる")
    Practice.create!(title: "sudoをインストールする")
    Practice.create!(title: "sshdをインストールする")
    Practice.create!(title: "リモートのサーバーにsshで鍵を使ってログインする")
    Practice.create!(title: "sshdでパスワード認証を禁止にする")
    Practice.create!(title: "sshdでrootでのログインを禁止にする")
    Practice.create!(title: "telnetを使ってget, postを試し、HTTPの基礎を理解する")
    Practice.create!(title: "HTTPのrequestとresponse、headerとbodyを理解する")
    Practice.create!(title: "nginxをインストールする")
    Practice.create!(title: "nginxにネームベースのVirtualHostを使ってサイトを作る")
    Practice.create!(title: "sslの基礎を理解する")
    Practice.create!(title: "nginxで自己認証した証明書を使ったssl対応サイトを作る")
    Practice.create!(title: "sqlの基礎を理解する")
    Practice.create!(title: "mysqlをインストールする")
    Practice.create!(title: "mysql, mysqladminコマンドでユーザー、データベース、テーブルを作成する")
    Practice.create!(title: "rubyをインストールする")
    Practice.create!(title: "rvmをインストールする")
    Practice.create!(title: "rvmで複数バージョンのrubyを切り替えれるようにする")
    Practice.create!(title: "「プログラミング入門 - Rubyを使って」をやる")
    Practice.create!(title: "「プログラミング入門 - Rubyを使って」をgithubにpushする")
    Practice.create!(title: "「プログラミング入門 - Rubyを使って」のテストをrspecで書く")
    Practice.create!(title: "rubygemsの基礎を理解する")
    Practice.create!(title: "gemコマンドを使ってgemのインストール、更新、削除をする")
    Practice.create!(title: "rakeの基礎を理解する")
    Practice.create!(title: "rakeでCプログラムをコンパイルするRakefileを書く")
    Practice.create!(title: "Getting Started with RailsにしたがってRailsアプリを作る")
    Practice.create!(title: "ActionControllerを理解する")
    Practice.create!(title: "ActionViewを理解する")
    Practice.create!(title: "ActiveRecordを理解する")
    Practice.create!(title: "ActiveSupportを理解する")
    Practice.create!(title: "Railsのroutesを理解する")
    Practice.create!(title: "Railsのi18nの基礎を理解する")
    Practice.create!(title: "sorceryを使ってユーザー認証を作る")
    Practice.create!(title: "sorceryを使ってTwitter認証を作る")
    Practice.create!(title: "exception_notificationを使ってエラーのメール通知機能を作る")
    Practice.create!(title: "paperclipを使って画像アップロード機能を作る")
    Practice.create!(title: "TDDの基礎を理解する")
    Practice.create!(title: "unittestの基礎を理解する")
    Practice.create!(title: "rspecを使ってRailsアプリのテストを書く")
    Practice.create!(title: "capybaraを使ってrequest specを書く")
    Practice.create!(title: "Try Gitをやる")
    Practice.create!(title: "unicornを使ってrailsアプリを動かす")
    Practice.create!(title: "capistranoを使ってrailsアプリをデプロイする")
    Practice.create!(title: "capistrano-extを使ってstaging環境にアプリをデプロイする")

  end

  def down
    Practice.all.each do |practice|
      practice.destory
    end
  end
end
