# システムテストの削減候補

[ADR 0003](adr/0003-test-layer-policy.md)の基準に沿って、直す、消す、移す候補をまとめた一覧です。作業が済んだ項目はこの一覧から消します。

## 元にした記録

- 2026-11-22のmainのCI（run 44995744889）の成果物 `test-timings` を使いました。
- ブラウザーを使うシステムテストは1374件、合計2635秒です。8シャードで並行に走るため、CI全体の時間への効果は合計時間の8分の1ほどです。
- 区分は、テストの題名と本文を正規表現で調べて機械的に付けました。区分どうしは重なります。A以外は、1件ずつの確認をまだしていません。着手するときに、テストの本文と下の層のテストを読んで確かめます。
- 時間の見込みは概算です。

## まとめ

| 区分 | 内容 | 件数 | 今の時間 | 減る見込み |
| --- | --- | --- | --- | --- |
| A | 書き方を直す（テストは残す） | 30 | 約610秒 | 約580秒 |
| B | 重複しているので消す、または1つにまとめる | 約90 | 約190秒 | 約150秒 |
| C | 下の層へ移す（C-5を除く） | 約380 | 約620秒 | 約450秒 |
| C-6 | JavaScriptの単体テストへ移す（Cの内数を含む） | 約30 | 約60秒 | 約50秒 |
| C-5 | 操作をしない表示の確認（調査が必要） | 約400 | 約320秒 | 未定 |

Aは振る舞いを変えずに済み、効果も最も大きいので、最初に行います。

## A. 書き方を直す

テストは残します。待ち時間の上限（`Capybara.default_max_wait_time = 15`）まで待っている箇所を直します。

### A-1. 非表示のチェックボックスを `visible: false` で操作している（14件、約350秒）

`check 'x', allow_label_click: true, visible: false` は、非表示の入力要素を直接操作しようとして上限まで待ち、そのあとでラベルをクリックします。呼び出し1回につき約17秒かかっています。呼び出しが1回のテストは中央値17.6秒、2回のテストは34秒前後でした。`visible: false` を付けていない同種の呼び出しを含むテスト（63件）は、入会のテストを除いて5秒以内に終わっています。

直し方の案は、`visible: false` を外すか、ラベルを直接クリックすることです。直したあとに時間を計って確かめます。

| ファイル | 行 | 今の時間 |
| --- | --- | --- |
| `test/system/admin/users_test.rb` | 115, 130, 132, 167, 181, 183, 273, 276, 305, 318, 330, 331 | 約190秒 |
| `test/system/grant_course_applications_test.rb` | 24〜27, 39, 67 | 86秒 |
| `test/system/mentor/courses_test.rb` | 30, 37 | 36秒 |
| `test/system/practices/mentor_test.rb` | 102 | 18秒 |
| `test/system/practice/memos_test.rb` | 8 | 18秒 |

`grant_course_applications_test.rb` の25行目と26行目は同じ行の重複です。

### A-2. 「あること」の判定で、ないことを確かめている（9件、約150秒）

`assert_not has_button?` や、結果を使っていない `has_selector?` は、要素が現れるのを上限まで待ちます。ないことを確かめている箇所は `assert_no_button` などに、あることを確かめたい箇所（`graduation_test.rb` の更新成功のメッセージなど）は `assert_text` や `assert_selector` に置き換えます。どちらにするかは、テストごとの期待する結果で決めます。

| 場所 | 該当する行 | 今の時間 |
| --- | --- | --- |
| `test/system/api/check/reports_test.rb:6` | `assert_not has_button? '日報を確認'` | 16秒 |
| `test/system/home/grass_test.rb:7` | `assert_not has_button? '非表示'` | 17秒 |
| `test/system/users/profile_test.rb:111` | `assert_not has_button? '非表示'` | 16秒 |
| `test/system/practices_test.rb:43` | `assert_not has_link? '修了'` | 16秒 |
| `test/system/notification/graduation_test.rb:15` | `has_css?('p.flash__message', ...)`（結果を使っていない） | 17秒 |
| `test/system/question/tags_test.rb:37` | `has_selector?('card-list-item')`（結果を使っていない） | 17秒 |
| `test/system/user/tags_test.rb:95`, `116` | 同上 | 34秒 |
| `test/system/bookmark/talks_test.rb:12` | `if !page.has_text?(...)` | 16秒 |

`has_selector?('card-list-item')` は、クラスを表す `.` がなく、結果も使っていないため、何も確かめていません。直前の `has_no_selector?('card-list-item')` も同じです。

### A-3. `all` が空であることを確かめている（5件、約80秒）

`test/system/generations/filter_test.rb` の62, 79, 96, 113, 130行目の `assert_empty all('.a-user-role.is-retired')` は、要素が1つ現れるのを上限まで待ちます。`assert_no_selector` に置き換えます。このファイルはB-3の対象でもあります。

### A-4. タグ入力の補助メソッドが上限まで待つ（2件、約32秒）

`test/supports/tag_helper.rb:50` の `has_selector?("input[type='hidden'][name*='tag_list']", visible: :all)` は、Reactでない画面では上限まで待ちます。`test/system/article/tags_test.rb:16` と `test/system/movie/tags_test.rb:6` が該当します。

### A-5. 原因が未確認の遅いテスト

入会のテスト（`sign_up_test.rb`、`sign_up/card_test.rb`、`sign_up/trainee_test.rb`、`notification/signed_up_test.rb`）は1件で21〜25秒かかります。Stripeの入力欄を使うテストで、原因はまだ調べていません。主要な流れなので残し、時間の内訳を調べます。

## B. 重複しているので消す、または1つにまとめる

### B-1. 問い合わせと企業研修の問い合わせのコメント（16件、19秒）

`test/system/comment/corporate_training_inquiry_comments_test.rb` は、`test/system/comment/inquiry_comments_test.rb` の名前を置き換えただけの内容です。名前をそろえて比べると、違いは2行でした。どちらも同じコメントの部品を使っています。企業研修の側は、コメントを1件投稿できることの確認だけを残します。

### B-2. コメントの共通の振る舞いを対象ごとに確かめている（約20件、約30秒）

「コメントとプレビューのタブがある」「二重送信を防ぐ」「絵文字つきで投稿する」「画像つきで投稿する」「投稿後に送信ボタンが有効に戻る」などを、`base_comments_test.rb`、`report_comments_test.rb`、`inquiry_comments_test.rb` がそれぞれ確かめています。`base_comments_test.rb` に寄せ、対象ごとのファイルには、その対象だけの振る舞い（確認つきコメントなど）を残します。

### B-3. 役割や対象だけを変えた繰り返し（32件、124秒）

| ファイル | 件数 | 時間 | 内容 |
| --- | --- | --- | --- |
| `generations/filter_test.rb` | 5 | 65秒 | 絞り込みの対象（研修生、アドバイザーなど）ごとに同じ確認 |
| `notification/signed_up_test.rb` | 4 | 30秒 | 入会する役割ごとに、入会の操作を最初から行う |
| `users/search_test.rb` | 4 | 8秒 | 対象ごとの検索 |
| `talks/search_test.rb` | 5 | 7秒 | 役割ごとの検索 |
| `users/access_control_test.rb` | 4 | 6秒 | 役割ごとのアクセス制御 |
| `notification/hibernation_test.rb` | 3 | 4秒 | 役割ごとの休会通知 |
| `notification/talk_test.rb` | 3 | 3秒 | 役割ごとの表示 |
| `user/companies_test.rb` | 4 | 1秒 | 役割ごとの所属表示 |

画面の確認は1件にし、対象ごとの違いはモデルやクエリーのテストで並べて確かめます。

### B-4. ブックマーク、タグ、リアクション、足あと、Watchを対象ごとに確かめている（約60件、約110秒）

- **ブックマーク**: 「ブックマークする」「外す」「ボタンの状態」を、Docs、提出物、相談部屋、Q&A、お知らせ、動画、イベント、定期イベントのそれぞれで確かめています（`bookmark/`、`bookmarks/`）。
- **タグ**: 「存在するタグ名に変更」「存在しないタグ名に変更」「同じ値に変更」を、ユーザー、Q&A、Docs、動画のそれぞれで確かめています（`user/tags_test.rb`、`question/tags_test.rb`、`page/tags_test.rb`、`movie/tags_test.rb`）。
- **リアクション、足あと、Watch**: `reaction/`、`reactions/`、`footprint/`、`watches_test.rb`、`reports/watch_test.rb`、`pages/watch_test.rb` が対象ごとにあります。

操作は1つの対象で確かめ、ほかの対象は部品が表示されることだけを確かめます。タグ名の変更の場合分けは、モデルのテストへ移します。

## C. 下の層へ移す

件数と時間は、Aで数えたテストを除いた数字です。C-1からC-4は互いに重なるため、まとめの表には重なりを除いた合計を載せています。

### C-1. 通知（82件、210秒）

`test/system/notification/` は、画面を操作して通知を発生させ、通知の一覧に出ることを確かめています。通知が作られること、宛先、文面は、`test/models/`、`test/notifiers/activity_notifier_test.rb`、`test/deliveries/activity_delivery_test.rb`、`test/mailers/activity_mailer_test.rb`（79件）で確かめられます。システムテストには、通知が画面に出て、開くと既読になる流れを数件だけ残します。

時間の大きいファイルは、`questions_test.rb`（15件、38秒）、`mention_test.rb`（6件、34秒）、`signed_up_test.rb`（4件、30秒）、`reports_test.rb`（6件、25秒）、`graduation_test.rb`（1件、17秒）、`pair_works_test.rb`（6件、15秒）、`articles_test.rb`（7件、14秒）です。

移す前に、下の層に同じ場合分けのテストがあるかを1件ずつ確かめます。

### C-2. 権限と、見えないことの確認（約155件、約190秒）

題名に「できない」「見えない」「管理者以外」などを含むテストです。`test/integration/` で、役割と期待するステータスを並べて確かめます。

- `test/system/require_login_test.rb`（2件、18秒）: ログインが必要な37のパスを、ブラウザーで1つずつ開いています。結合テストで同じ確認ができます。
- `test/system/product/unchecked_test.rb`（7件、14秒）
- `test/system/users_test.rb`（5件、9秒）
- `test/system/users/access_control_test.rb`（4件、6秒）
- `test/system/admin/users_test.rb`（5件、5秒）
- `test/system/admin/companies_test.rb`（3件、4秒）

### C-3. 並び順、絞り込み、検索（約105件、約150秒）

条件の場合分けはモデルやクエリーのテストへ移し、画面では絞り込みが働くことを1件だけ確かめます。

- `test/system/users/search_test.rb`（17件、40秒）
- `test/system/talks/search_test.rb`（17件、21秒）
- `test/system/searchables/user_search_test.rb`（8件、10秒）
- `test/system/practice/questions_test.rb`（5件、8秒）

### C-4. 入力検証（約50件、約100秒）

検証の規則はモデルのテストで確かめます。画面では、エラーが表示されることを機能ごとに1件だけ確かめます。

- `test/system/questions/tag_test.rb`（4件、10秒）
- `test/system/page/tags_test.rb`（4件、7秒）
- `test/system/retirements/validation_test.rb`（2件、4秒）
- `test/system/practices/mentor_test.rb`（3件、3秒）

### C-5. 操作をしない表示の確認（約400件、約320秒）

クリックも入力もせず、ページを開いて表示を確かめるテストです。2026-11-17に、rack_testで通るものは `*_browserless_test.rb` へ移してあります。残りはJavaScriptでの描画に頼っています。件数が多いので、次の順で調べます。

1. 表示する内容がサーバー側のデータで決まるものは、APIのレスポンスやコンポーネントのテストで確かめます。
2. 同じページを開くテストが複数あるものは、1件にまとめます。ページを開く回数が減ります。

時間の大きいファイルは、`users/profile_test.rb`（8件、25秒）、`home/events_test.rb`（7件、12秒）、`home/required_fields_test.rb`（8件、10秒）、`practices_test.rb`（12件、9秒）、`users/list_test.rb`（7件、7秒）です。

### C-6. JavaScriptの単体テストへ移す（約30件、約60秒）

`test/javascript/` には `node --test` で走るテスト（`*.mjs`）が4ファイルあり、CIの `check` ジョブで実行しています。ブラウザーを使わず、全体で1秒もかかりません。DOMに頼らない変換や判定は、ここで確かめられます。

- **Markdownの変換**: `markdown_test.rb`（10件、15秒）、`reports/markdown_test.rb`（8件、12秒）、`markdown_link_test.rb`（4件、9秒）は、入力したMarkdownがどのHTMLになるかを画面で確かめています。`app/javascript/markdown-it-*.js` の変換は、`markdown_wiki_link_test.mjs` と同じ方法で確かめられます。画面では、プレビューが表示されることを1件だけ確かめます。
- **タグ名の検証**: 空白を含むタグ、ドットだけのタグ、先頭の `#` の扱いを、`questions/tag_test.rb`、`page/tags_test.rb`、`current_user/tags_test.rb`、`user/tags_test.rb` が画面で確かめています（11件、20秒）。判定は `app/javascript/validate-tag-name.js` にあります。

クリックへの反応や表示の切り替えなど、DOMを操作するコードは、今の仕組みでは確かめられません。jsdomなどの導入が必要になるため、ここでは対象にしていません。

## 残すもの

次のテストはブラウザーを使うシステムテストとして残します。

- 入会と決済（`sign_up_test.rb`、`sign_up/`）
- 日報の作成と提出（`reports/`）
- 提出物の提出と確認（`products/`、`product/`）
- 質問と回答（`questions/`）
- 休会と退会（`hibernation_test.rb`、`retirements/`）
- Markdownエディターなど、JavaScriptで動く入力の部品（`markdown_test.rb` など）

## 進め方

1. Aを1つのPRで直し、時間を計ります。
2. B-1、B-3のように根拠がはっきりしているものから、機能ごとにPRを分けて進めます。
3. Cは、下の層のテストを先に追加してから、システムテストを消します。
