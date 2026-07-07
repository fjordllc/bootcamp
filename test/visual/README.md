# ビジュアルリグレッションテスト

ページのスクリーンショットを撮り、コミット済みのベースライン画像とピクセル単位で
比較して **意図しない見た目の変化** を検出します。CSS リファクタなど「見た目を
変えないはずの変更」の安全網です。

- 基盤: 既存の Minitest system test（Capybara + `capybara-playwright-driver`）
- 比較: [`capybara_screenshot_diff`](https://github.com/donv/capybara_screenshot_diff)
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
bundle install                 # capybara_screenshot_diff を導入（Gemfile.lock 更新）
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

### 3. 意図した変更でベースラインを更新

デザインを意図的に変えたら、該当ベースラインを削除して再生成し、差分画像を
レビューしてからコミットします。

```sh
rm test/visual/screenshots/report_show.png
bin/rails test test/visual/pages_visual_test.rb -n /report_show/
git add test/visual/screenshots/report_show.png
```

## このリファクタの検証（before / after ワンショット）

`css_refactor` ブランチが本当に見た目を変えていないかは、`main` で撮った
ベースラインをこのブランチで比較すれば確認できます（同一環境で実行すること）。

```sh
git switch main
bin/rails test test/visual/pages_visual_test.rb        # main のベースライン生成
git switch css_refactor
git checkout main -- test/visual/screenshots           # main の画像を持ち込む
bin/rails test test/visual/pages_visual_test.rb        # 差分ゼロなら見た目不変
```

## 動的コンテンツの扱い

`application_visual_test_case.rb` で以下を自動化しています。

- `travel_to` による時刻固定（相対時間・経過日数バッジの安定化）
- transition / animation / キャレットの無効化 CSS 注入
- アバター・草（グラフ）・時刻など非決定要素のマスク（`DEFAULT_MASK_SELECTORS`）
- フォント・画像のロード待ち、描画の安定待ち（`stability_time_limit`）

ページ固有の動的要素は、各テストで `capture('name', mask: [...])` に
セレクタを渡してマスクを追加してください。

## 再開時の TODO（現状メモ）

足場（ベースクラス・サンプルテスト・gem 追加・.gitignore・本ドキュメント）は
コミット済み。**実行系はまだ回していない**ので、再開時は以下を上から順に。

1. [ ] `bundle install` を実行して `Gemfile.lock` に `capybara_screenshot_diff`
       を反映（この作業はまだ未実施）。
2. [ ] `npx playwright install chromium` でブラウザを用意。
3. [ ] `bin/rails test test/visual/pages_visual_test.rb` を **CI と同じ
       Linux 環境**で実行し、ベースラインを生成 → 内容を確認して
       `test/visual/screenshots/` をコミット。
4. [ ] サンプルテストの assert セレクタ・マスク対象（`DEFAULT_MASK_SELECTORS`）
       を実ページに合わせて微調整。差分画像 `*.diff.png` を見ながら安定化。
5. [ ] 安定したら「このリファクタの検証」節の before/after 手順で
       `main` ↔ `css_refactor` を比較し、見た目不変を実ブラウザで裏取り。
6. [ ] CI（`.github/workflows/ci.yml`）へステップ追加（下記）。
7. [ ] 対象ページを代表画面から徐々に拡張。

補足: CSS リファクタ本体（デッドコード削除・色の変数化など）は `css_refactor`
ブランチに別途コミット済みで、コンパイル後 CSS の値不変は検証済み。本ビジュアル
テストはその実描画での裏取りが目的。

## CI への組み込み（任意）

既存の system test ジョブ（`.github/workflows/ci.yml`、ubuntu-latest + chromium）
と同じ環境なので、そこにビジュアルテストのステップと、失敗時の
`test/visual/screenshots/**/*.diff.png` のアーティファクト保存を追加すれば
そのまま回せます。ベースラインは必ずこの CI 環境で生成・更新してください。
