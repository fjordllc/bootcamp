# frozen_string_literal: true

# Linuxの教科書 seed データ

textbook = Textbook.find_or_initialize_by(title: 'Linux')
textbook.description = 'Linuxの基本操作からシェルスクリプトまで、実践的に学べる教科書です。'
textbook.published = true
textbook.save!

# チャプターとセクションの定義
chapters_data = [
  {
    title: 'Linuxを使ってみよう',
    sections: [
      { title: 'Linuxとは何か', body: <<~MD, estimated_minutes: 5, goals: ['Linuxの概要を説明できる', 'Linuxが使われている場面を挙げられる'], key_terms: ['Linux', 'カーネル', 'ディストリビューション'] },
        ## Linuxとは

        Linuxは、1991年にリーナス・トーバルズによって開発が始まったオペレーティングシステム（OS）です。

        正確には、Linux自体は「カーネル」と呼ばれるOSの中核部分を指します。このカーネルに様々なソフトウェアを組み合わせたものを「Linuxディストリビューション」と呼びます。

        ## Linuxが使われている場面

        Linuxは私たちの身の回りで広く使われています。

        - **Webサーバー** — インターネット上のサーバーの大部分がLinuxで動いています
        - **スマートフォン** — AndroidはLinuxカーネルをベースにしています
        - **クラウドサービス** — AWS、GCPなどのクラウド基盤はLinuxが主流です
        - **組み込み機器** — ルーターやIoTデバイスにも使われています

        ## なぜLinuxを学ぶのか

        Webエンジニアにとって、Linuxの知識は必須です。開発したアプリケーションが動く環境の多くがLinuxだからです。Linuxの基本操作を身につけることで、開発・運用の現場で自信を持って作業できるようになります。
      MD
      { title: 'Linuxディストリビューション', body: <<~MD, estimated_minutes: 5, goals: ['主要なディストリビューションの違いを説明できる', '自分の用途に合ったディストリビューションを選べる'], key_terms: ['Ubuntu', 'CentOS', 'Debian', 'ディストリビューション'] },
        ## ディストリビューションとは

        Linuxカーネル単体ではOSとして使えません。カーネルにシェル、コマンド、ライブラリ、パッケージ管理システムなどを組み合わせて配布されるものを**ディストリビューション**（通称ディストロ）と呼びます。

        ## 主要なディストリビューション

        ### Debian系
        - **Ubuntu** — デスクトップ用途で最も人気。初心者に優しい
        - **Debian** — 安定性重視。サーバー用途に強い

        ### Red Hat系
        - **CentOS / AlmaLinux / Rocky Linux** — 企業サーバーで広く使われている
        - **Fedora** — 最新技術をいち早く取り入れる

        ### その他
        - **Arch Linux** — 上級者向け。自分で一から構築する
        - **Alpine Linux** — 軽量。Dockerコンテナでよく使われる

        ## この教科書の環境

        この教科書では**Ubuntu**を前提に解説します。他のディストリビューションでもコマンドの基本は同じですが、パッケージ管理などで違いがある場合は補足します。
      MD
      { title: 'ターミナルを開いてみよう', body: <<~MD, estimated_minutes: 4, goals: ['ターミナルを起動できる', '簡単なコマンドを実行できる'], key_terms: ['ターミナル', 'コマンドライン', 'プロンプト'] },
        ## ターミナルとは

        ターミナル（端末）は、キーボードからコマンドを入力してコンピュータを操作するためのアプリケーションです。

        GUIでマウスをクリックして操作するのとは異なり、テキストベースで操作します。最初は戸惑うかもしれませんが、慣れるととても効率的に作業できるようになります。

        ## ターミナルを起動する

        Ubuntuでは、以下の方法でターミナルを起動できます。

        - `Ctrl + Alt + T` キーを押す
        - アプリケーションメニューから「端末」を選ぶ

        ## プロンプト

        ターミナルを開くと、以下のような表示が出ます。

        ```
        komagata@ubuntu:~$
        ```

        これを**プロンプト**と呼びます。「コマンドを入力してください」という合図です。

        - `komagata` — ユーザー名
        - `ubuntu` — ホスト名
        - `~` — 現在のディレクトリ（ホームディレクトリ）
        - `$` — 一般ユーザーであることを示す（rootユーザーの場合は `#`）

        ## 最初のコマンド

        試しに `date` と入力してEnterを押してみましょう。

        ```bash
        $ date
        2026年 3月 26日 木曜日 20:00:00 JST
        ```

        現在の日時が表示されます。これがLinuxでのコマンド実行の基本です。
      MD
    ]
  },
  {
    title: 'シェルって何だろう？',
    sections: [
      { title: 'シェルの役割', body: <<~MD, estimated_minutes: 5, goals: ['シェルの役割を説明できる', 'カーネルとシェルの関係を理解する'], key_terms: ['シェル', 'カーネル', 'インタプリタ'] },
        ## シェルとは

        シェル（shell）は、ユーザーとカーネルの間を取り持つプログラムです。「殻」という意味で、カーネル（核）を包む殻のような存在です。

        ユーザーがターミナルに入力したコマンドを受け取り、それをカーネルに伝え、結果をユーザーに返します。

        ## シェルの動作の流れ

        1. ユーザーがコマンドを入力する
        2. シェルがコマンドを解釈する
        3. シェルがカーネルにリクエストを送る
        4. カーネルが処理を実行する
        5. 結果がシェルを通じてユーザーに表示される

        ## なぜシェルが必要なのか

        カーネルは直接人間の言葉を理解できません。シェルが「通訳」の役割を果たすことで、私たちは人間に近い形でコンピュータに指示を出せます。

        シェルは単なる通訳ではなく、変数、条件分岐、ループなどのプログラミング機能も持っています。これを活用したものが「シェルスクリプト」です。
      MD
      { title: 'シェルの種類', body: <<~MD, estimated_minutes: 4, goals: ['主要なシェルの種類を挙げられる', '自分が使っているシェルを確認できる'], key_terms: ['bash', 'zsh', 'sh', 'fish'] },
        ## 主なシェル

        Linuxには複数のシェルがあります。

        | シェル | 正式名 | 特徴 |
        |--------|--------|------|
        | sh | Bourne Shell | 最も古いシェル。POSIX標準 |
        | bash | Bourne Again Shell | shの後継。Linux標準 |
        | zsh | Z Shell | bash互換で高機能。macOSの標準 |
        | fish | Friendly Interactive Shell | 初心者に優しい。補完が強力 |

        ## この教科書で使うシェル

        この教科書では**bash**を使います。Linuxで最も広く使われており、シェルスクリプトの標準的な実行環境です。

        ## 自分のシェルを確認する

        現在使っているシェルは以下のコマンドで確認できます。

        ```bash
        $ echo $SHELL
        /bin/bash
        ```

        `/bin/bash` と表示されればbashを使っています。
      MD
      { title: 'コマンドの基本構文', body: <<~MD, estimated_minutes: 5, goals: ['コマンド・オプション・引数の関係を理解する', 'マニュアルを参照できる'], key_terms: ['コマンド', 'オプション', '引数', 'man'] },
        ## コマンドの書き方

        Linuxのコマンドは基本的に以下の形式です。

        ```
        コマンド [オプション] [引数]
        ```

        - **コマンド** — 実行したい命令（例: `ls`, `cp`, `mkdir`）
        - **オプション** — コマンドの動作を変更する（例: `-l`, `--all`）
        - **引数** — コマンドの対象（例: ファイル名、ディレクトリ名）

        ## 例

        ```bash
        $ ls -l /home
        ```

        - `ls` — ファイル一覧を表示するコマンド
        - `-l` — 詳細表示するオプション
        - `/home` — 表示対象のディレクトリ（引数）

        ## オプションの書き方

        オプションには2つの書き方があります。

        - **短いオプション** — `-` + 1文字（例: `-l`, `-a`）
        - **長いオプション** — `--` + 単語（例: `--all`, `--help`）

        短いオプションは複数まとめて書けます。

        ```bash
        $ ls -la    # ls -l -a と同じ
        ```

        ## マニュアルを見る

        コマンドの使い方がわからないときは `man` コマンドを使います。

        ```bash
        $ man ls
        ```

        `q` キーで終了できます。
      MD
    ]
  },
  {
    title: 'シェルの便利な機能',
    sections: [
      { title: 'コマンド履歴', body: <<~MD, estimated_minutes: 4, goals: ['コマンド履歴を活用できる', 'historyコマンドを使える'], key_terms: ['history', '↑キー', 'Ctrl+R'] },
        ## コマンド履歴とは

        bashは過去に実行したコマンドを記録しています。これを**コマンド履歴**と呼びます。同じコマンドを何度も入力する手間を省けます。

        ## 履歴の使い方

        ### ↑↓キーで呼び出す
        - `↑` キー — 1つ前のコマンドを表示
        - `↓` キー — 1つ後のコマンドを表示

        ### historyコマンド
        ```bash
        $ history
          1  ls
          2  cd /home
          3  cat file.txt
        ```

        ### Ctrl+R で検索
        `Ctrl+R` を押すと、履歴を検索できます。文字を入力すると、一致するコマンドが表示されます。

        ```
        (reverse-i-search)`cat': cat file.txt
        ```

        Enterで実行、`Ctrl+C` でキャンセルできます。

        ## 履歴ファイル

        コマンド履歴は `~/.bash_history` ファイルに保存されています。ターミナルを閉じても履歴は残ります。
      MD
      { title: 'タブ補完', body: <<~MD, estimated_minutes: 3, goals: ['タブ補完を使いこなせる'], key_terms: ['タブ補完', 'Tab'] },
        ## タブ補完とは

        コマンドやファイル名を途中まで入力して `Tab` キーを押すと、残りを自動的に補完してくれる機能です。

        ## 使い方

        例えば、`/etc/hostname` というファイルを表示したい場合:

        ```bash
        $ cat /etc/hostn[Tab]
        ```

        `Tab` を押すと、自動的に以下のように補完されます。

        ```bash
        $ cat /etc/hostname
        ```

        ## 候補が複数ある場合

        候補が複数ある場合は、`Tab` を2回押すと候補一覧が表示されます。

        ```bash
        $ cat /etc/host[Tab][Tab]
        host.conf  hostname   hosts
        ```

        さらに文字を入力して絞り込み、再度 `Tab` を押せば補完されます。

        ## タブ補完を習慣にしよう

        タブ補完は**タイプミスを防ぎ、入力を速くする**最も基本的なテクニックです。Linuxを使うときは常に `Tab` キーを意識しましょう。
      MD
      { title: 'ワイルドカード', body: <<~MD, estimated_minutes: 4, goals: ['*と?の違いを説明できる', 'ワイルドカードを使ってファイルを指定できる'], key_terms: ['ワイルドカード', '*', '?', 'グロブ'] },
        ## ワイルドカードとは

        ワイルドカードは、ファイル名のパターンを指定するための特殊文字です。複数のファイルをまとめて指定したいときに使います。

        ## 主なワイルドカード

        ### `*` — 任意の文字列（0文字以上）

        ```bash
        $ ls *.txt        # .txtで終わるファイルすべて
        $ ls test*        # testで始まるファイルすべて
        $ ls *.rb         # .rbで終わるファイルすべて
        ```

        ### `?` — 任意の1文字

        ```bash
        $ ls file?.txt    # file1.txt, fileA.txt など
        $ ls ???.rb       # 3文字.rb にマッチ
        ```

        ### `[ ]` — 指定した文字のいずれか

        ```bash
        $ ls file[123].txt   # file1.txt, file2.txt, file3.txt
        $ ls file[a-z].txt   # filea.txt〜filez.txt
        ```

        ## 注意点

        ワイルドカードを展開するのはシェルです。コマンドに渡される前に、シェルがワイルドカードを実際のファイル名に置き換えます。

        これを**グロブ展開**と呼びます。
      MD
    ]
  },
  {
    title: 'ファイルとディレクトリ',
    sections: [
      { title: 'ファイルシステムの構造', body: <<~MD, estimated_minutes: 5, goals: ['Linuxのディレクトリ構造を説明できる', '主要なディレクトリの役割を知る'], key_terms: ['ルートディレクトリ', 'ディレクトリツリー', 'FHS'] },
        ## Linuxのディレクトリ構造

        Linuxのファイルシステムは1つの**ルートディレクトリ** `/` から始まる木構造（ツリー構造）になっています。Windowsのように `C:` `D:` といったドライブの概念はありません。

        ## 主要なディレクトリ

        ```
        /
        ├── bin/     ← 基本コマンド
        ├── etc/     ← 設定ファイル
        ├── home/    ← ユーザーのホームディレクトリ
        ├── tmp/     ← 一時ファイル
        ├── usr/     ← ユーザー用プログラム
        ├── var/     ← 可変データ（ログなど）
        └── root/    ← rootユーザーのホーム
        ```

        | ディレクトリ | 役割 |
        |-------------|------|
        | `/bin` | 基本的なコマンド（ls, cpなど） |
        | `/etc` | システムの設定ファイル |
        | `/home` | 各ユーザーのホームディレクトリ |
        | `/tmp` | 一時ファイル（再起動で消える） |
        | `/usr` | ユーザー向けプログラムやライブラリ |
        | `/var` | ログ、メール、データベースなど |

        ## FHS

        このディレクトリ構造は **FHS**（Filesystem Hierarchy Standard）という標準で定められています。ほとんどのLinuxディストリビューションがこの規格に従っています。
      MD
      { title: '絶対パスと相対パス', body: <<~MD, estimated_minutes: 4, goals: ['絶対パスと相対パスの違いを説明できる', '適切なパスの書き方を選べる'], key_terms: ['絶対パス', '相対パス', 'カレントディレクトリ', '.', '..'] },
        ## パスとは

        ファイルやディレクトリの場所を示す文字列を**パス**と呼びます。パスには2種類あります。

        ## 絶対パス

        ルートディレクトリ `/` から始まるパスです。どのディレクトリにいても同じファイルを指します。

        ```bash
        /home/komagata/documents/memo.txt
        ```

        ## 相対パス

        現在のディレクトリ（カレントディレクトリ）を基準にしたパスです。

        ```bash
        documents/memo.txt
        ```

        ### 特殊な表記

        - `.` — カレントディレクトリ自身
        - `..` — 1つ上のディレクトリ（親ディレクトリ）
        - `~` — ホームディレクトリ

        ```bash
        $ cd ..          # 1つ上に移動
        $ cat ./memo.txt # カレントディレクトリのmemo.txt
        $ cd ~/documents # ホームのdocumentsに移動
        ```

        ## どちらを使うか

        - **スクリプトや設定ファイル** → 絶対パスが安全
        - **日常の操作** → 相対パスが便利
      MD
      { title: 'ホームディレクトリとカレントディレクトリ', body: <<~MD, estimated_minutes: 3, goals: ['pwdでカレントディレクトリを確認できる', 'cdで移動できる'], key_terms: ['ホームディレクトリ', 'カレントディレクトリ', 'pwd', 'cd'] },
        ## ホームディレクトリ

        ログインしたときに最初にいるディレクトリが**ホームディレクトリ**です。通常 `/home/ユーザー名` にあります。

        `~`（チルダ）はホームディレクトリを表す省略記号です。

        ```bash
        $ echo ~
        /home/komagata
        ```

        ## カレントディレクトリ

        今いるディレクトリを**カレントディレクトリ**（作業ディレクトリ）と呼びます。

        ### 確認する: pwd

        ```bash
        $ pwd
        /home/komagata/documents
        ```

        ### 移動する: cd

        ```bash
        $ cd /tmp        # /tmpに移動
        $ cd documents   # documentsに移動（相対パス）
        $ cd             # ホームに戻る
        $ cd -           # 直前のディレクトリに戻る
        ```

        `cd` を引数なしで実行するとホームディレクトリに戻ります。迷ったら `cd` だけ打てば安全な場所に戻れます。
      MD
    ]
  },
  {
    title: 'ファイル操作の基本',
    sections: [
      { title: 'ファイルの一覧を見る', body: "lsコマンドの基本的な使い方を学びます。`ls`、`ls -l`、`ls -la`の違いを理解し、ファイルの詳細情報を読めるようになります。", estimated_minutes: 5, goals: ['lsコマンドのオプションを使い分けられる'], key_terms: ['ls', '-l', '-a'] },
      { title: 'ファイルを作成・削除する', body: "touchでファイルを作成し、rmで削除する方法を学びます。`rm -r`によるディレクトリの再帰的削除や、`rm -i`による確認付き削除も扱います。", estimated_minutes: 5, goals: ['ファイルの作成と削除ができる'], key_terms: ['touch', 'rm', 'rm -r'] },
      { title: 'ディレクトリを作成・削除する', body: "mkdirでディレクトリを作成し、rmdirで削除する方法を学びます。`mkdir -p`で深い階層を一度に作る方法も扱います。", estimated_minutes: 4, goals: ['ディレクトリの作成と削除ができる'], key_terms: ['mkdir', 'rmdir', 'mkdir -p'] },
      { title: 'ファイルをコピー・移動する', body: "cpでコピー、mvで移動（リネーム）する方法を学びます。ディレクトリのコピーには`cp -r`が必要なことも理解します。", estimated_minutes: 5, goals: ['ファイルのコピーと移動ができる'], key_terms: ['cp', 'mv', 'cp -r'] },
      { title: 'ファイルの中身を見る', body: "cat、less、headコマンドでファイルの内容を表示する方法を学びます。大きなファイルにはlessが便利なことを理解します。", estimated_minutes: 4, goals: ['ファイルの内容を確認できる'], key_terms: ['cat', 'less', 'head', 'tail'] },
    ]
  },
  {
    title: '探す、調べる',
    sections: [
      { title: 'findでファイルを探す', body: "findコマンドでファイル名、種類、更新日時などの条件でファイルを検索する方法を学びます。", estimated_minutes: 5, goals: ['findコマンドで条件を指定してファイルを探せる'], key_terms: ['find', '-name', '-type'] },
      { title: 'grepでファイルの中身を検索する', body: "grepコマンドでファイル内のテキストを検索する方法を学びます。`-r`で再帰検索、`-i`で大文字小文字の無視も扱います。", estimated_minutes: 5, goals: ['grepでテキスト検索ができる'], key_terms: ['grep', '-r', '-i', '-n'] },
      { title: 'whichとwhereisでコマンドの場所を調べる', body: "which、whereisコマンドでコマンドの実体ファイルがどこにあるかを調べる方法を学びます。", estimated_minutes: 3, goals: ['コマンドのパスを調べられる'], key_terms: ['which', 'whereis', 'PATH'] },
    ]
  },
  {
    title: 'テキストエディタ',
    sections: [
      { title: 'Vimの基本操作', body: "Vimの起動・終了、ノーマルモードとインサートモードの切り替え、保存と終了の方法を学びます。", estimated_minutes: 7, goals: ['Vimでファイルを開いて編集・保存・終了できる'], key_terms: ['Vim', 'ノーマルモード', 'インサートモード', ':wq'] },
      { title: 'Vimでの移動と編集', body: "hjklでのカーソル移動、dd（行削除）、yy（コピー）、p（ペースト）、u（アンドゥ）などの基本操作を学びます。", estimated_minutes: 5, goals: ['Vimの基本的な編集操作ができる'], key_terms: ['hjkl', 'dd', 'yy', 'p', 'u'] },
      { title: 'Vimの検索と置換', body: "/で検索、:s/old/new/gで置換する方法を学びます。nとNで検索結果を移動する方法も扱います。", estimated_minutes: 4, goals: ['Vimで検索と置換ができる'], key_terms: ['/', ':s', 'n', 'N'] },
    ]
  },
  {
    title: 'bashの設定',
    sections: [
      { title: '環境変数', body: "環境変数の概念、export、echo $変数名での確認方法を学びます。PATHやHOMEなど重要な環境変数も扱います。", estimated_minutes: 5, goals: ['環境変数を設定・確認できる'], key_terms: ['環境変数', 'export', 'PATH', 'HOME'] },
      { title: '.bashrcと.bash_profile', body: "bashの設定ファイル（.bashrc、.bash_profile）の違いと役割を学びます。エイリアスやプロンプトのカスタマイズも扱います。", estimated_minutes: 5, goals: ['bashの設定ファイルを編集できる'], key_terms: ['.bashrc', '.bash_profile', 'alias', 'source'] },
      { title: 'PATHを通す', body: "PATHの仕組みを理解し、自分のスクリプトやツールにパスを通す方法を学びます。", estimated_minutes: 4, goals: ['PATHの仕組みを理解し、パスを通せる'], key_terms: ['PATH', 'export PATH'] },
    ]
  },
  {
    title: 'ファイルパーミッション、スーパーユーザ',
    sections: [
      { title: 'パーミッションの読み方', body: "ls -lの出力にあるrwxの意味を学びます。所有者・グループ・その他の3つの権限区分を理解します。", estimated_minutes: 5, goals: ['パーミッション表記を読める'], key_terms: ['パーミッション', 'rwx', '所有者', 'グループ'] },
      { title: 'chmodでパーミッションを変更する', body: "chmodコマンドで数値表記（755など）と記号表記（u+xなど）でパーミッションを変更する方法を学びます。", estimated_minutes: 5, goals: ['chmodでパーミッションを変更できる'], key_terms: ['chmod', '755', '644', 'u+x'] },
      { title: 'スーパーユーザとsudo', body: "rootユーザーの概念と、sudoコマンドで一時的に管理者権限を使う方法を学びます。", estimated_minutes: 4, goals: ['sudoの使い方と注意点を理解する'], key_terms: ['root', 'sudo', 'su'] },
    ]
  },
  {
    title: 'プロセスとジョブ',
    sections: [
      { title: 'プロセスとは', body: "プロセスの概念、psコマンドでのプロセス一覧表示、PIDの意味を学びます。", estimated_minutes: 5, goals: ['プロセスの概念を理解し、一覧を表示できる'], key_terms: ['プロセス', 'ps', 'PID', 'ps aux'] },
      { title: 'ジョブとフォアグラウンド・バックグラウンド', body: "ジョブの概念、&でのバックグラウンド実行、fg/bgでの切り替え、Ctrl+Zでの一時停止を学びます。", estimated_minutes: 5, goals: ['ジョブをフォアグラウンド・バックグラウンドで制御できる'], key_terms: ['ジョブ', 'fg', 'bg', '&', 'Ctrl+Z'] },
      { title: 'プロセスを終了する', body: "killコマンドでプロセスを終了する方法、シグナルの種類（SIGTERM、SIGKILL）を学びます。", estimated_minutes: 4, goals: ['killコマンドでプロセスを終了できる'], key_terms: ['kill', 'SIGTERM', 'SIGKILL', 'kill -9'] },
    ]
  },
  {
    title: '標準入出力とパイプライン',
    sections: [
      { title: '標準入力・標準出力・標準エラー出力', body: "3つのストリーム（stdin, stdout, stderr）の概念を学びます。コマンドのデータの流れを理解します。", estimated_minutes: 5, goals: ['3つの標準ストリームを説明できる'], key_terms: ['標準入力', '標準出力', '標準エラー出力', 'stdin', 'stdout', 'stderr'] },
      { title: 'リダイレクト', body: ">, >>, <, 2>によるリダイレクトを学びます。コマンドの出力をファイルに保存したり、エラーを分離する方法を理解します。", estimated_minutes: 5, goals: ['リダイレクトでファイルに出力を保存できる'], key_terms: ['リダイレクト', '>', '>>', '2>'] },
      { title: 'パイプライン', body: "|（パイプ）でコマンドをつなげる方法を学びます。複数のコマンドを組み合わせてデータを加工する考え方を理解します。", estimated_minutes: 5, goals: ['パイプでコマンドを組み合わせられる'], key_terms: ['パイプ', '|', 'パイプライン'] },
    ]
  },
  {
    title: 'テキスト処理',
    sections: [
      { title: 'sortとuniq', body: "sortで行をソートし、uniqで重複を除去する方法を学びます。パイプと組み合わせたデータ集計の基本を扱います。", estimated_minutes: 4, goals: ['sortとuniqでデータを整理できる'], key_terms: ['sort', 'uniq', 'sort -n', 'sort -r'] },
      { title: 'cutとpaste', body: "cutで列を抽出し、pasteでファイルを横に結合する方法を学びます。CSVやTSVデータの処理を扱います。", estimated_minutes: 4, goals: ['cutとpasteでデータを加工できる'], key_terms: ['cut', 'paste', '-d', '-f'] },
      { title: 'wcとtr', body: "wcで行数・単語数・文字数を数え、trで文字を変換・削除する方法を学びます。", estimated_minutes: 3, goals: ['wcとtrを使えるようになる'], key_terms: ['wc', 'tr', 'wc -l'] },
    ]
  },
  {
    title: '正規表現',
    sections: [
      { title: '正規表現の基本', body: "正規表現とは何か、なぜ必要かを学びます。メタ文字（., *, ^, $, [ ]）の基本的な使い方を理解します。", estimated_minutes: 6, goals: ['基本的なメタ文字を使った正規表現を書ける'], key_terms: ['正規表現', 'メタ文字', '.', '*', '^', '$'] },
      { title: '拡張正規表現', body: "+、?、|、( )など拡張正規表現のメタ文字を学びます。grep -Eやegrepでの使い方を扱います。", estimated_minutes: 5, goals: ['拡張正規表現を使える'], key_terms: ['拡張正規表現', '+', '?', '|', 'grep -E'] },
      { title: '正規表現の実践', body: "IPアドレス、メールアドレス、日付などの実践的なパターンマッチを学びます。grepと組み合わせた活用例を扱います。", estimated_minutes: 5, goals: ['実用的な正規表現を書ける'], key_terms: ['文字クラス', '量指定子', 'バックリファレンス'] },
    ]
  },
  {
    title: '高度なテキスト処理',
    sections: [
      { title: 'sedの基本', body: "sedコマンドでテキストの置換・削除・挿入を行う方法を学びます。ファイルを直接編集する-iオプションも扱います。", estimated_minutes: 6, goals: ['sedで基本的なテキスト処理ができる'], key_terms: ['sed', 's/old/new/', '-i', 'd'] },
      { title: 'awkの基本', body: "awkで列指定の処理、パターンマッチ、簡単な計算を行う方法を学びます。ログ解析の基本を扱います。", estimated_minutes: 6, goals: ['awkで列を指定した処理ができる'], key_terms: ['awk', '$1', 'NR', 'NF', 'BEGIN', 'END'] },
    ]
  },
  {
    title: 'シェルスクリプトを書こう',
    sections: [
      { title: '最初のシェルスクリプト', body: "シェルスクリプトの作成方法、シバン（#!/bin/bash）、実行権限の付与、実行方法を学びます。", estimated_minutes: 5, goals: ['シェルスクリプトを作成して実行できる'], key_terms: ['シェルスクリプト', 'シバン', '#!/bin/bash', 'chmod +x'] },
      { title: '変数と引数', body: "シェルスクリプトでの変数の使い方、コマンドライン引数（$1, $2, $@, $#）の受け取り方を学びます。", estimated_minutes: 5, goals: ['変数と引数を扱える'], key_terms: ['変数', '$1', '$@', '$#', '$?'] },
      { title: 'echoとread', body: "echoで出力し、readでユーザー入力を受け取る方法を学びます。対話的なスクリプトの作り方を扱います。", estimated_minutes: 3, goals: ['入出力を扱えるスクリプトが書ける'], key_terms: ['echo', 'read', '-p'] },
    ]
  },
  {
    title: 'シェルスクリプトの基礎知識',
    sections: [
      { title: '条件分岐（if文）', body: "if文の書き方、testコマンド（[ ]）、文字列比較、数値比較、ファイルテストを学びます。", estimated_minutes: 6, goals: ['if文で条件分岐が書ける'], key_terms: ['if', 'then', 'fi', 'test', '[ ]'] },
      { title: 'ループ（for, while）', body: "forループ、whileループの書き方を学びます。ファイル一覧の処理や、条件付きの繰り返し処理を扱います。", estimated_minutes: 5, goals: ['forとwhileでループ処理が書ける'], key_terms: ['for', 'while', 'do', 'done'] },
      { title: '関数', body: "シェルスクリプトでの関数の定義方法、引数の受け渡し、戻り値（return, echo）を学びます。", estimated_minutes: 4, goals: ['関数を定義して使える'], key_terms: ['function', 'return', 'local'] },
    ]
  },
  {
    title: 'シェルスクリプトを活用しよう',
    sections: [
      { title: 'バックアップスクリプト', body: "日付付きのバックアップを自動作成するスクリプトの作り方を学びます。dateコマンドとの組み合わせを扱います。", estimated_minutes: 5, goals: ['実用的なバックアップスクリプトが書ける'], key_terms: ['date', 'cp', 'バックアップ'] },
      { title: 'ログ解析スクリプト', body: "アクセスログからIPアドレスや頻度を集計するスクリプトの作り方を学びます。awk, sort, uniqの組み合わせを扱います。", estimated_minutes: 5, goals: ['ログを集計するスクリプトが書ける'], key_terms: ['アクセスログ', '集計', 'awk'] },
      { title: 'cronで定期実行する', body: "crontabの書き方、スクリプトの定期実行設定を学びます。ログのローテーションや定期バックアップを扱います。", estimated_minutes: 4, goals: ['cronで定期実行を設定できる'], key_terms: ['cron', 'crontab', 'crontab -e'] },
    ]
  },
  {
    title: 'アーカイブと圧縮',
    sections: [
      { title: 'tarコマンド', body: "tarでファイルをまとめる（アーカイブ）方法、展開する方法を学びます。-c, -x, -f, -vオプションを扱います。", estimated_minutes: 4, goals: ['tarでアーカイブの作成と展開ができる'], key_terms: ['tar', 'アーカイブ', '-c', '-x', '-f'] },
      { title: 'gzipとbzip2', body: "gzip、bzip2による圧縮・展開の方法を学びます。tar.gzの作り方（tar czf）も扱います。", estimated_minutes: 4, goals: ['圧縮・展開ができる'], key_terms: ['gzip', 'bzip2', 'tar.gz', 'czf'] },
      { title: 'zipとunzip', body: "zipコマンドでの圧縮、unzipでの展開を学びます。WindowsやmacOSとのファイルやり取りで使う場面を扱います。", estimated_minutes: 3, goals: ['zip形式の圧縮・展開ができる'], key_terms: ['zip', 'unzip'] },
    ]
  },
  {
    title: 'バージョン管理システム',
    sections: [
      { title: 'バージョン管理とは', body: "バージョン管理の概念、なぜ必要か、Gitが生まれた背景を学びます。", estimated_minutes: 4, goals: ['バージョン管理の必要性を説明できる'], key_terms: ['バージョン管理', 'Git', 'リポジトリ'] },
      { title: 'Gitの基本操作', body: "git init, add, commit, status, logの基本的なワークフローを学びます。", estimated_minutes: 6, goals: ['Gitの基本操作ができる'], key_terms: ['git init', 'git add', 'git commit', 'git log'] },
      { title: 'ブランチとマージ', body: "ブランチの概念、作成・切り替え・マージの方法を学びます。コンフリクトの解決方法も扱います。", estimated_minutes: 6, goals: ['ブランチを使った開発ができる'], key_terms: ['branch', 'checkout', 'merge', 'コンフリクト'] },
    ]
  },
  {
    title: 'ソフトウェアパッケージ',
    sections: [
      { title: 'パッケージ管理とは', body: "パッケージ管理の概念、なぜ手動インストールではなくパッケージマネージャを使うべきかを学びます。", estimated_minutes: 4, goals: ['パッケージ管理の利点を説明できる'], key_terms: ['パッケージ', 'パッケージマネージャ', '依存関係'] },
      { title: 'apt（Debian系）', body: "apt update, apt install, apt remove, apt searchなどの基本的なパッケージ操作を学びます。", estimated_minutes: 5, goals: ['aptでパッケージの管理ができる'], key_terms: ['apt', 'apt update', 'apt install', 'apt remove'] },
      { title: 'yum/dnf（Red Hat系）', body: "yum（dnf）でのパッケージ管理を学びます。aptとの対応関係を理解します。", estimated_minutes: 4, goals: ['yum/dnfの基本操作を理解する'], key_terms: ['yum', 'dnf', 'rpm'] },
    ]
  },
]

# チャプターとセクションの作成
chapters_data.each_with_index do |chapter_data, chapter_index|
  chapter = textbook.chapters.find_or_initialize_by(title: chapter_data[:title])
  chapter.position = chapter_index
  chapter.save!

  chapter_data[:sections].each_with_index do |section_data, section_index|
    section = chapter.sections.find_or_initialize_by(title: section_data[:title])
    section.body = section_data[:body]
    section.estimated_minutes = section_data[:estimated_minutes]
    section.goals = section_data[:goals]
    section.key_terms = section_data[:key_terms]
    section.position = section_index
    section.save!
  end
end

puts "Linuxの教科書を作成しました: #{textbook.chapters.count}章 #{Textbook::Section.joins(:chapter).where(textbook_chapters: { textbook_id: textbook.id }).count}セクション"
