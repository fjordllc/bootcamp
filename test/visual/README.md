# ビジュアルリグレッションテスト

ページのスクリーンショットを撮り、ピクセル単位で比較して **意図しない見た目の
変化** を検出します。CSS を触るときに「レイアウトがズレていないか」を手元で
確かめるための、**ローカル専用**のツールです（CI には組み込みません）。

- 基盤: 既存の Minitest system test（Capybara + `capybara-playwright-driver`）
- 比較: [`capybara-screenshot-diff`](https://github.com/donv/capybara-screenshot-diff)（1.12 系。`require: false` で導入し、ベースクラスで `capybara_screenshot_diff/minitest` を require）
- ベースクラス: `test/application_visual_test_case.rb`
- テスト: `test/visual/*_test.rb`
- 画像: `test/visual/screenshots/`（`.gitignore` 済み。**画像はコミットしない**）
- 画像比較には ImageMagick を使う: `brew install imagemagick`

## ⚠️ 最重要: before / after は同じマシンで撮る

スクリーンショットはフォントのアンチエイリアスなどが **OS・マシンによって微妙に
異なります**。別環境で撮った画像同士を比べると、CSS を一切変えていなくても全面
差分になります。

**「変更前」と「変更後」は必ず同じマシン・同じブラウザで撮って比較してください。**
撮った画像は環境依存なので **リポジトリにコミットしないこと**（`test/visual/
screenshots/` は `.gitignore` 済み）。

## セットアップ

```sh
bundle install                 # capybara-screenshot-diff を導入（Gemfile.lock 更新済み）
npx playwright install chromium
```

## ローカルで画面のズレをチェックする（普段使い）

CSS を編集する前後でスクショを撮り、ピクセル比較して差分を見ます。**画像を
コミットする必要はありません**。テストは撮った画像を `test/visual/screenshots/`
に書き出すので、それを「変更前」「変更後」で退避して比べるだけです。

```sh
# 0) （初回だけ）ブラウザと ImageMagick
npx playwright install chromium
brew install imagemagick

# 1) 変更前の状態でスナップショットを撮って退避
bin/rails test test/visual/pages_visual_test.rb
mkdir -p tmp/visual/before && cp test/visual/screenshots/*.png tmp/visual/before/

# 2) ここで CSS を編集する
#    app/assets/stylesheets/*.css を編集したら Tailwind を再ビルド:
bin/rails tailwindcss:build

# 3) 変更後をもう一度撮る
rm -f test/visual/screenshots/*.png
bin/rails test test/visual/pages_visual_test.rb
mkdir -p tmp/visual/after && cp test/visual/screenshots/*.png tmp/visual/after/

# 4) 比較。差分ピクセル数を表示し、ズレた箇所は *.diff.png で可視化
for f in tmp/visual/before/*.png; do
  n=$(basename "$f")
  d=$(compare -metric AE "$f" "tmp/visual/after/$n" "tmp/visual/${n%.png}.diff.png" 2>&1)
  printf '%-16s %s px\n' "${n%.png}" "$d"
done
```

読み方:

- **0 または数十 px** … 実質一致（サブピクセルのアンチエイリアス揺れ）。ズレなし。
- **数千 px 以上** … どこかがズレている。`tmp/visual/<page>.diff.png` を開くと
  変わったピクセルが赤くハイライトされるので、そこを確認する。

差分が「自分が意図した変更」なら OK。意図していない箇所が赤くなっていたら
レイアウト崩れなので直す。`tmp/` は `.gitignore` 済みなので後片付けも不要。

> 補足（最初の1ページが遅い / タイムアウトするとき）: sprockets が CSS を初回
> コンパイルするため、キャッシュが冷えていると最初のページ遷移が数十秒かかり
> ます。落ちたらもう一度実行すれば、2 回目以降は warm で速くなります。

### 対象ページを増やす

`test/visual/pages_visual_test.rb` にテストを足すだけです。動的要素があれば
`capture('name', extra_mask: ['.selector'])` でマスクを追加します（次節参照）。

### （参考）gem 標準の pass/fail フロー

`bin/rails test` の合否だけで判定したい場合、gem は working tree のスクショを
**git の HEAD にコミット済みのベースライン**（`git show HEAD:<path>` で取得）と
比較します。つまりベースラインを一度コミットしておけば、以降は `bin/rails test`
の赤/緑でズレを検出できます。

> ⚠️ **未コミットのベースラインは比較されません（false green の罠）。** ローカルの
> `fail_if_new` は false なので、ベースラインが HEAD に無いと「新規＝pass」になり、
> 差分があっても緑になります。この方式を使うなら画像を commit すること（ただし
> 環境依存なので push はしない・ローカル限定運用）。普段使いは上の before/after
> 方式のほうが手軽で安全です。

## このリファクタの検証（before / after）— ✅ 実施済み

`css_refactor` が本当に見た目を変えていないかを、`main` の CSS と
`css_refactor` の CSS を **同一環境（同じ Mac・同じブラウザ・時刻固定）** で
描画して 6 ページをピクセル比較して裏取りしました。

やり方（上の「普段使い」と同じく、画像をコミットせず直接 before/after 比較）:

```sh
# 1. main のコンパイル済み CSS を app/assets/builds/ に入れて sprockets を warm、
#    6ページ生成 → before セットとして退避
# 2. css_refactor の CSS に差し替えて warm、6ページ生成 → after セット
# 3. before/after を ImageMagick で AE 比較（compare -metric AE a.png b.png）
```

結果（before=main CSS / after=css_refactor CSS、決定化の対応後）:

| ページ | 差分px | 判定 |
|---|---|---|
| dashboard / report_form / users_index / lp_practices | 0 | 完全一致 |
| report_show | 129 (0.007%) | サブピクセルの AA ノイズ |
| user_profile | 46 (0.002%) | サブピクセルの AA ノイズ |

→ **リファクタによる見た目の変化なし**を実描画で確認済み。残差はすべて許容値
（`TOLERANCE = 0.001` = 0.1%）を大きく下回るアンチエイリアスのゆらぎ。

同一 CSS で 2 回撮って比較する「再現性テスト」でも全ページ差分 0〜100px 未満で、
決定的に描画されることを確認しています。

> 補足: gem 標準の「main でベースライン生成 → ブランチで比較」フローでもよいが、
> その場合はベースラインを **commit してから** 比較すること（上の false-green の罠）。

## 動的コンテンツの扱い

`application_visual_test_case.rb` で以下を自動化しています。

- `travel_to` による時刻固定（相対時間・経過日数バッジの安定化）
- transition / animation / キャレットの無効化 CSS 注入
- アバター・草（グラフ）・時刻など非決定要素のマスク（`DEFAULT_MASK_SELECTORS`）
- フォント・画像のロード待ち、描画の安定待ち（`stability_time_limit`）

ページ固有の動的要素は、各テストで `capture('name', extra_mask: [...])` に
セレクタを渡すとデフォルトマスクに追加できます。

### 実際に踏んだ非決定要素（対応済み）

検証中に、CSS とは無関係に「実行ごとに描画が変わる」箇所がいくつか見つかったので
対応済み。同種の揺れに当たったら参考に。

- **コメントの表示順**（report show）: `report1` の 2 件のコメントが `created_at`
  同値でタイになり順序が非決定 → `test/fixtures/comments.yml` の `comment1` に
  明示 `created_at` を付与して決定化。
- **アバター画像**: 実体は `img.a-user-icon`（img 自身がクラス保持）。旧セレクタ
  `.a-user-icon img` では拾えないため `.a-user-icon` を DEFAULT_MASK に追加。
- **ユーザータグのサイドバー**（users index）: `_random_tags` が文字どおり
  ランダム抽出 → `.random-tags-items` を DEFAULT_MASK に追加。
- **「直近の日報」サイドパネル**（report show）: `@recent_reports` の並び／末尾
  カードの高さが非決定 → report show テストで `#side-tabs-content-1` を extra_mask。

## 進捗と残 TODO

ローカル（macOS）で実行系まで通し、リファクタの見た目不変を裏取り済み。

1. [x] `bundle install`（`Gemfile.lock` に `capybara-screenshot-diff` 反映済み）。
2. [x] `npx playwright install chromium`。
3. [x] `bin/rails test test/visual/pages_visual_test.rb` が 6 ページ green で実行可能。
4. [x] マスク・並び順の微調整（上「実際に踏んだ非決定要素」参照）。同一 CSS 2 回撮りで
       全ページ再現性を確認。
5. [x] before/after で `main` ↔ `css_refactor` を実描画比較し、**見た目不変を裏取り**
       （上「このリファクタの検証」参照）。
6. [—] CI 組み込みは **見送り**。スクショが環境依存で不安定になりやすいため、
       ローカルで手元確認する用途に割り切る。
7. [ ] 対象ページを代表画面から徐々に拡張。

補足:
- CSS リファクタ本体（デッドコード削除・色の変数化など）は `css_refactor` に別途
  コミット済みで、コンパイル後 CSS の値不変も検証済み。本テストは実描画での裏取り。
- ローカル検証は同一 Mac 環境での **CSS 差し替え比較**で行った（画像はリポジトリに
  コミットしていない ＝ 環境依存の画像を履歴に残していない）。

## CI には組み込まない

ビジュアル差分は OS・マシンでスクショが微妙に変わり CI では不安定になりやすいので、
**あえて CI には載せず、ローカルで手元確認するツール**として運用します。上の
「ローカルで画面のズレをチェックする」手順を、CSS を触ったときに回してください。

CI から外すために 2 段で守っています:

- `.circleci/config.yml` のテスト glob で `test/visual/` を除外
  （`... | grep -v '^test/visual/' | ...`）。CI はこれらを実行しない。
- 保険として、`ApplicationVisualTestCase` の setup で `ENV['CI']` がある場合は
  `skip` する。CI 環境では gem の `fail_if_new` が true になり、コミット済み
  ベースラインが無いと全テストが失敗するため（この失敗を避ける）。
