# FBC Design System — AI Context Document

このドキュメントは、AIにデザイン・実装を依頼する際に渡すコンテキストファイルです。
bootcamp.fjord.jp のUIルールをまとめています。

---

## 技術スタック

- **CSS**: Tailwind CSS v4 + カスタムCSS（CSS変数ベース）
- **テンプレート**: Slim
- **コンポーネント**: ViewComponent（`app/components/`）
- **アイコン**: Font Awesome 6 Pro
- **フォント**: YakuHanJPs + Noto Sans JP（`--sans-serif`）、Source Code Pro（`--monospace`）
- **JS**: Hotwire (Turbo + Stimulus) + Vue.js（一部）

---

## カラーパレット

### ブランドカラー
| 名前 | 値 | 用途 |
|------|-----|------|
| `--main` | `hsl(242, 51%, 51%)` | ページタイトル、主要アクセント |
| `--primary` | `#5752e8` | ボタン、リンクフォーカス、選択状態 |
| `--accent` | `hsl(44, 96%, 54%)` | 警告、ハイライト（ゴールド系） |

### セマンティックカラー
| 名前 | 値 | 用途 |
|------|-----|------|
| `--success` | `hsl(150, 39%, 49%)` | 成功、完了、フラッシュ（notice） |
| `--info` | `hsl(190, 73%, 48%)` | 情報、補足 |
| `--warning` | `hsl(44, 96%, 54%)` | 警告（= accent） |
| `--danger` | `hsl(349, 90%, 62%)` | エラー、削除、フラッシュ（alert） |
| `--disabled` | `hsl(242, 11%, 85%)` | 無効状態 |

### テキスト
| 名前 | 値 | 用途 |
|------|-----|------|
| `--default-text` | `hsl(242, 10%, 30%)` | 本文テキスト |
| `--muted-text` | `hsl(242, 5%, 64%)` | 補助テキスト、メタ情報 |
| `--semi-muted-text` | `hsl(242, 7%, 57%)` | muted よりやや濃い |
| `--link-text` | `hsl(242, 62%, 33%)` | リンク |
| `--hover-text` | `hsl(215, 78%, 50%)` | リンクホバー |
| `--reversal-text` | `white` | 色付き背景上のテキスト |

### 背景
| 名前 | 値 | 用途 |
|------|-----|------|
| `--base` | `white` | カード、ヘッダーなどの背景 |
| `--background` | `hsl(242, 34%, 98%)` | ページ全体の背景（ほぼ白、微紫） |
| `--background-tint` | `hsl(242, 20%, 93%)` | やや濃い背景 |
| `--background-shade` | `hsl(242, 11%, 85%)` | 区切り、無効状態の背景 |
| `--background-semi-shade` | `hsl(242, 24%, 92%)` | 中間のシェード |

### ボーダー
| 名前 | 値 | 用途 |
|------|-----|------|
| `--border` | `hsl(242, 7%, 89%)` | 通常のボーダー |
| `--border-tint` | `hsl(242, 14%, 95%)` | 薄いボーダー |
| `--border-shade` | `hsl(242, 7%, 84%)` | 濃いめのボーダー |

### セマンティック tint/text ペア（アラート・バッジ背景用）
各セマンティックカラーには `*-text` と `*-tint` のペアがある：
- `--danger-text` / `--danger-tint` — エラーメッセージの文字色と背景色
- `--success-text` / `--success-tint`
- `--info-text` / `--info-tint`
- `--warning-text` / `--warning-tint`
- `--primary-text` / `--primary-tint`

### 設計方針
- **hue 242（紫）ベース**: グレー系（テキスト、ボーダー、背景）もすべて hue 242 で統一。純粋なグレーは使わない。

---

## インプット

### テキスト入力（`.a-text-input`）
```
通常:     bg: var(--input-background)  border: var(--input-border)
ホバー:   bg: white                    border: var(--input-hover-border)
フォーカス: bg: white                    border: #5752e8
          box-shadow: rgba(87, 82, 232, 0.4) 0 0 1px 2px
無効:     bg: var(--background)         color: var(--muted-text)
エラー:   border: #e1a7b6              bg: #fefafb
```
- `border-radius: 0.25rem`
- `padding: 0.5rem`
- textarea の `min-height: 10rem`

---

## タイポグラフィ

### フォントファミリー
- **本文**: `var(--sans-serif)` = YakuHanJPs, "Noto Sans JP", system-ui fallback
- **コード**: `var(--monospace)` = "Source Code Pro", monospace

### フォントサイズ（よく使うもの）
| コンテキスト | デスクトップ | モバイル |
|-------------|------------|---------|
| ページタイトル | 1.25rem | 1rem |
| カードヘッダー | 1rem | 0.875rem |
| 本文 | 0.9375rem | 0.8125rem |
| メタ・補助 | 0.875rem | 0.75rem |
| 小さいテキスト | 0.75rem | 0.625rem |

---

## スペーシング

### ページ全体
- ヘッダー高さ: `3.125rem`（デスクトップ）/ `2.75rem`（モバイル）
- グローバルナビ幅: `5.75rem`（アイコンのみ）/ `13rem`（展開時）
- サイドナビ幅: `17rem`
- コンテナ padding: `1.5rem`（デスクトップ）/ `1rem`（モバイル）

### コンテナサイズ
```
.container.is-xxxl  →  max-width: 108rem
.container.is-xxl   →  max-width: 96rem
.container.is-xl    →  max-width: 80rem
.container.is-lg    →  max-width: 64rem
.container.is-md    →  max-width: 48rem
.container.is-sm    →  max-width: 40rem
.container.is-xs    →  max-width: 32rem
.container.is-xxs   →  max-width: 28rem
```

### カード間の余白
- デスクトップ: `1.25rem`
- モバイル: `1rem`

---

## ブレイクポイント

| 名前 | 値 | 用途 |
|------|-----|------|
| sm | `max-width: 47.9375em` (≈767px) | モバイル |
| md | `min-width: 48em` (≈768px) | タブレット以上 |
| lg | `min-width: 64em` (≈1024px) | デスクトップ |
| xl | `min-width: 80em` (≈1280px) | ワイドデスクトップ |

---

## 共通パーツ

### border-radius
- ほぼすべて `0.25rem`（ボタン、カード、インプット、バッジ等）
- バッジのみ `1em`（pill型）

### transition
- 標準: `all 0.2s ease-out`（ボタン）
- インプット: `border-color 0.2s ease-in, background-color 0.2s ease-in, box-shadow 0.2s ease-in`

### focus 表現
- `box-shadow: 0 0 0 0.1875rem rgba(カラー, 0.25)`（ボタン）
- `box-shadow: rgba(87, 82, 232, 0.4) 0 0 1px 2px`（インプット）

---

## コンポーネント一覧

### Atoms（`a-` プレフィックス）
最小のUIパーツ。単体で使える。

| クラス | 用途 |
|--------|------|
| `.a-button` | ボタン（バリエーション後述） |
| `.a-card` | カードコンテナ |
| `.a-badge` | バッジ / ラベル |
| `.a-text-input` | テキスト入力 / textarea |
| `.a-form-label` | フォームラベル |
| `.a-form-help` | フォームヘルプテキスト |
| `.a-meta` | メタ情報（日付、投稿者等） |
| `.a-tags` | タグ一覧 |
| `.a-dropdown` | ドロップダウン |
| `.a-table` | テーブル |
| `.a-border` | 区切り線（`<hr>`） |
| `.a-user-icon` | ユーザーアイコン |
| `.a-user-icons` | ユーザーアイコン一覧 |
| `.a-user-name` | ユーザー名表示 |
| `.a-bookmark-button` | ブックマークボタン |
| `.a-watch-button` | ウォッチボタン |
| `.a-copy-button` | コピーボタン |
| `.a-switch` | トグルスイッチ |
| `.a-link-card` | リンクカード（OGP的な） |
| `.a-notice-block` | 通知ブロック |
| `.a-panels` | パネルグループ |
| `.a-side-nav` | サイドナビゲーション |

### ボタン（`.a-button`）バリエーション

**カラー**:
- `.is-primary` — 紫（#5752e8）、白文字。メインアクション
- `.is-secondary` — 白背景、グレーボーダー。サブアクション
- `.is-success` — 緑。完了・承認
- `.is-danger` — 赤。削除・危険な操作
- `.is-warning` — ゴールド。注意
- `.is-info` — シアン。情報
- `.is-main` — main色。ページレベルのアクション
- `.is-muted` — 控えめ。ボーダーなし、グレー背景
- `.is-muted-bordered` — muted + ボーダー
- `.is-primary-border` — 紫ボーダー、透明背景
- `.is-disabled` / `:disabled` — 無効

**サイズ**:
- `.is-xxs` — 0.625rem、h: 1.4rem
- `.is-xs` — 0.75rem、h: 1.7rem
- `.is-sm` — 0.75rem、h: 2rem
- `.is-md` — 0.8125rem、h: 2.25rem
- `.is-lg` — 1rem、h: 2.75rem
- `.is-xl` — 1.25rem、h: 57px

**その他**:
- `.is-block` — 全幅
- `.is-icon` — アイコンのみ
- `.is-text` — テキストリンク風（下線つき）
- `.is-back` — 戻るボタン（左矢印つき）

### バッジ（`.a-badge`）バリエーション
カラーはボタンと同じ体系（`.is-primary`, `.is-secondary`, etc.）
サイズ: `.is-xs`, `.is-sm`, `.is-md`, `.is-lg`, `.is-xl`
形状: pill型（`border-radius: 1em`）

### カード（`.a-card`）
```slim
.a-card
  .card-header
    .card-header__inner
      .card-header__title タイトル
      .card-header__action
        / アクションボタン等
  .card-body
    .card-body__inner
      / コンテンツ
  .card-footer
    / フッター
```
- `background: white`, `border: 1px solid var(--border)`, `border-radius: 0.25rem`
- `.is-danger` バリエーション: 赤ボーダー、薄赤背景
- `.is-toggle`: 折りたたみカード

### ページ構造ブロック

```slim
/ 典型的なページ構造
main.page
  .page-header
    .container.is-xxxl
      .page-header__inner
        .page-header__start
          h2.page-header__title ページタイトル
        .page-header__end
          / アクションボタン

  .page-body
    .container.is-xxxl
      .page-body__inner
        .page-body__rows
          / コンテンツ

/ 2カラムレイアウト
  .page-body
    .container.is-xxxl
      .page-body__inner
        .page-body__columns
          .page-body__column.is-main
            / メインコンテンツ
          .page-body__column.is-sub
            / サイドバー
```

### フォーム構造
```slim
.form
  .form-item
    = label_tag :field, 'ラベル', class: 'a-form-label'
    = text_field_tag :field, nil, class: 'a-text-input'
    .a-form-help ヘルプテキスト
  .form-actions
    = submit_tag '送信', class: 'a-button is-primary is-md'
```

### カードリスト
```slim
.card-list
  .card-list-item
    .card-list-item__inner
      .card-list-item-title
      .card-list-item-meta
      .card-list-item-actions
```

### フラッシュメッセージ
- `.flash.is-notice` — 緑（success）背景
- `.flash.is-alert` — 赤（danger）背景
- テキストは白（`--reversal-text`）、中央寄せ

### ページ内メッセージブロック
```html
<div class="message warning">注意テキスト</div>
<div class="message danger">エラーテキスト</div>
<div class="message info">情報テキスト</div>
<div class="message success">成功テキスト</div>
<div class="message primary">プライマリテキスト</div>
```
- 各色の `*-tint` 背景 + `*-text` 文字色
- Font Awesome アイコン付き

### 空状態
```slim
.o-empty-message
  .o-empty-message__icon
    i.fa-regular.fa-sad-tear
  .o-empty-message__text
    | まだデータがありません。
```

---

## ViewComponent 一覧

| コンポーネント | 用途 |
|---------------|------|
| `PageTabsComponent` / `PageTabComponent` | ページ内タブナビ |
| `SubTabsComponent` / `SubTabComponent` | サブタブ |
| `ReactionsComponent` | リアクション（絵文字） |
| `SearchablesComponent` | 検索結果表示 |
| `GrassComponent` | GitHub風の活動グラフ |
| `NicoNicoCalendarComponent` | ニコニコカレンダー |
| `ActionCompletedButtonComponent` | 完了ボタン |
| `StudyStreakTrackerComponent` | 学習ストリーク表示 |
| `PracticeContentToggleComponent` | プラクティス内容の折りたたみ |
| `ProductComponent` / `UserProductsComponent` | 提出物表示 |
| `WorkComponent` | 作品表示 |
| `LearningComponent` | 学習記録 |

---

## CSS命名規則

### 原則
- **Atoms**: `a-` プレフィックス（例: `a-button`, `a-card`）
- **ブロック**: 機能名（例: `page-header`, `card-body`, `form-item`）
- **状態**: `is-` プレフィックス（例: `is-active`, `is-primary`, `is-sm`）
- **レイアウト**: `l-` プレフィックス（例: `l-container`）
- **ユーティリティ**: Tailwind v4 のユーティリティクラスも併用可

### BEM風の構造
```
.block
  .block__element
    .block__element.is-modifier
```
例: `.card-header__title`, `.a-button.is-primary.is-lg`

---

## ページテンプレート例（日報一覧）

```slim
- title '日報'

main.page-main
  header.page-main-header
    .container
      .page-main-header__inner
        .page-main-header__start
          h1.page-main-header__title
            | 日報
        .page-main-header__end
          = link_to '日報を書く', new_report_path, class: 'a-button is-primary is-sm'

  hr.a-border

  nav.pill-nav
    ul.pill-nav__items
      li.pill-nav__item
        = link_to '全て', reports_path, class: 'pill-nav__item-link is-active'
      li.pill-nav__item
        = link_to '未チェック', reports_unchecked_index_path, class: 'pill-nav__item-link'

  .page-body
    - if @reports.empty?
      .o-empty-message
        .o-empty-message__icon
          i.fa-regular.fa-sad-tear
        .o-empty-message__text
          | 日報はまだありません。
    - else
      / カードリスト表示
```

---

## やってはいけないこと（アンチパターン）

1. **純粋なグレーを使わない** — `#ccc`, `#999` 等ではなく `hsl(242, ...)` ベースのグレーを使う
2. **角丸を大きくしすぎない** — 基本 `0.25rem`。pill型バッジ以外で `1rem` 以上の角丸は使わない
3. **独自のフォーカス表現を作らない** — `box-shadow` ベースの既存パターンに従う
4. **ボタンに独自クラスを作らない** — `.a-button` + modifier で表現する
5. **カードの入れ子を深くしない** — `.a-card > .card-header + .card-body + .card-footer` の構造を守る
6. **Tailwindユーティリティの乱用** — レイアウトの微調整（`mt-2`, `px-4`等）には使ってOKだが、コンポーネントのスタイルは既存のカスタムCSSクラスを優先する
7. **色を直接指定しない** — `color: red` ではなく `var(--danger)` を使う

---

## AIへの指示テンプレート

以下をコピーして使ってください：

```
## 前提
- このプロジェクトのデザインシステムは docs/DESIGN_SYSTEM.md に従ってください
- テンプレートは Slim 記法です
- 既存のCSSクラス（a-button, a-card 等）を優先して使ってください
- 色はCSS変数（--primary, --danger 等）を使ってください
- レスポンシブはブレイクポイント（48em, 64em, 80em）に従ってください

## 参考ページ
（ここにスクショやテンプレートファイルを貼る）

## 作りたいもの
（ここに要件を書く）
```
