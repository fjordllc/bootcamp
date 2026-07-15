# ビジュアルリグレッションテスト

ページのスクリーンショットを撮り、コミット済みのベースライン画像とピクセル単位で
比較して **意図しない見た目の変化** を検出します。CSS リファクタなど「見た目を
変えないはずの変更」の安全網です。

- 基盤: 既存の Minitest system test（Capybara + `capybara-playwright-driver`）
- 比較: [`capybara-screenshot-diff`](https://github.com/donv/capybara-screenshot-diff)（1.12 系。`require: false` で導入し、ベースクラスで `capybara_screenshot_diff/minitest` を require）
- ベースクラス: `test/application_visual_test_case.rb`
- テスト: `test/visual/*_test.rb`
- 画像: `test/visual/screenshots/`（ベースラインは git 管理、差分/一時画像は `.gitignore`）

## ⚠️ 最重要: 描画環境を固定する

スクリーンショットはフォントのアンチエイリアスなどが **OS によって異なる** ため、
macOS で生成したベースラインを Linux（CI）で比較すると全ページ差分になります。

**ベースラインの生成と比較は必ず同じ環境で行ってください。** 推奨は CI と同じ
Ubuntu、またはそれに合わせた Docker コンテナです。ローカル Mac で撮った画像は
コミットしないこと。

## セットアップ

```sh
bundle install                 # capybara-screenshot-diff を導入（Gemfile.lock 更新済み）
npx playwright install chromium
```

## 使い方

### 1. ベースラインを生成（初回 / 意図的な変更時）

ベースライン画像が無い状態でテストを実行すると、その回のスクショが新しい
ベースラインとして保存されます（テストは pending 扱い）。

```sh
bin/rails test test/visual/pages_visual_test.rb
git add test/visual/screenshots
git commit -m "Add visual regression baselines"
```

### 2. 比較（通常のテスト実行）

ベースラインが存在する状態で実行すると、現在の描画と比較します。差分が許容値を
超えるとテストが失敗し、`*.diff.png` が出力されます。

```sh
bin/rails test test/visual/pages_visual_test.rb
```

> ⚠️ **ベースラインは commit していないと比較されません（false green の罠）。**
> このgemは working tree のスクショを **git 管理下のベースライン**（`git show
> HEAD:<path>` で取り出す）と比較します。ベースラインが未追跡・未コミットだと
> 「新規ベースライン＝pending 扱いで pass」になり、**差分があっても緑になります**。
> 実際に比較させたいベースラインは必ず commit 済みにしておくこと。

### 3. 意図した変更でベースラインを更新

デザインを意図的に変えたら、該当ベースラインを削除して再生成し、差分画像を
レビューしてからコミットします。

```sh
rm test/visual/screenshots/report_show.png
bin/rails test test/visual/pages_visual_test.rb -n /report_show/
git add test/visual/screenshots/report_show.png
```

## このリファクタの検証（before / after）— ✅ 実施済み

`css_refactor` が本当に見た目を変えていないかを、`main` の CSS と
`css_refactor` の CSS を **同一環境（同じ Mac・同じブラウザ・時刻固定）** で
描画して 6 ページをピクセル比較して裏取りしました。

やり方（README の commit 前提を避けるため、git を介さず直接比較する方式）:

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
6. [ ] CI（`.github/workflows/ci.yml`）へステップ追加（任意・下記）。**未対応**。
7. [ ] 対象ページを代表画面から徐々に拡張。

補足:
- CSS リファクタ本体（デッドコード削除・色の変数化など）は `css_refactor` に別途
  コミット済みで、コンパイル後 CSS の値不変も検証済み。本テストは実描画での裏取り。
- ローカル検証は同一 Mac 環境での **CSS 差し替え比較**で行った（ベースラインを
  リポジトリに commit していない ＝ macOS 画像を履歴に残していない）。CI に載せる
  場合は §「CI への組み込み」の通り Linux 環境でベースラインを生成・コミットする。

## CI への組み込み（任意）

既存の system test ジョブ（`.github/workflows/ci.yml`、ubuntu-latest + chromium）
と同じ環境なので、そこにビジュアルテストのステップと、失敗時の
`test/visual/screenshots/**/*.diff.png` のアーティファクト保存を追加すれば
そのまま回せます。ベースラインは必ずこの CI 環境で生成・更新してください。
