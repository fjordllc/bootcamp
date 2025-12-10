# Sass → CSS 移行方針メモ

## 現状
- エントリーポイント (`application.sass`/`lp.sass`/`not-logged-in.sass`) はすべて `@use` ベースに変換済み。
- 共通関数・変数・ミックスインは `config/**` 以下に集約し、必要なファイルからのみ `@use` する構造に整理。
- ビルドは `sass-embedded` + `sass-loader@14` を使用し、旧 API 依存の警告は `silenceDeprecations` で抑制している。

## 今後の方針
1. **CSS Custom Properties の活用**
   - カラーや余白などを `:root` 定義のカスタムプロパティへ移行し、Sass 変数から段階的に置換。
   - Sass ミックスインのうち単純なものは CSS ユーティリティや `@layer` へ置き換える。
2. **モジュール境界の明確化**
   - 新規 Sass は必ず `@use`/`@forward` を経由させ、グローバル名前空間を汚さない。
   - 共有が必要なものは専用のファイル（例: `config/mixins/_forms.sass`）で `@forward` する。
3. **Sass 固有機能の縮小**
   - `@extend` は mixin/utility class に置換。（例: `.a-text-input` のベース mixin 化）
   - `color.mix` など標準化された API 以外は、最終的に `color-mix()` などのネイティブ CSS へ移譲。
4. **段階ごとのチェックリスト**
   - [ ] CSS 変数セットの整備（`config/variables/css-variables`）。
   - [ ] 依存する Sass から順に CSS 変数を参照するよう更新。
   - [ ] 変換したモジュール単位で純 CSS 出力を検証し、将来的に Sass を削除しても崩れない状態にする。

## 運用ルール
- `@import` の追加は禁止。既存の追加が必要な場合は `@sass-migrator` を使用してから手作業で最適化する。
- 共有関数・ミックスインは `sass:` 標準モジュールか CSS 機能を優先し、新規の独自機能は必要最小限に留める。
- 大規模コンポーネントは依存を局所化し、将来的に CSS Modules や PostCSS パイプラインへ移行しやすい構造を保つ。

## CSS 変換候補（@use 未使用ファイル）
- atoms/_a-block-check.sass
- atoms/_a-card.sass
- atoms/_a-checkbox.sass
- atoms/_a-count-badge.sass
- atoms/_a-image-check.sass
- atoms/_a-meta.sass
- atoms/_a-on-off-checkbox.sass
- atoms/_a-page-notice.sass
- atoms/_a-side-nav.sass
- atoms/_a-table.sass
- atoms/_a-text-input.sass
- atoms/_a-user-role-badge.sass
- config/variables/_fonts.sass
- config/variables/_layout.sass
- config/variables/_text-inputs-list.sass
