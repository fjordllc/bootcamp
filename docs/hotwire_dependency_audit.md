# Hotwire Dependency Audit

React 削除後に Shakapacker/Webpack から importmap + Hotwire へ完全移行するための npm 依存棚卸し。

## Hotwire Core

| package | usage | migration note |
| --- | --- | --- |
| `@hotwired/turbo-rails` | `app/javascript/hotwire.js` | `config/importmap.rb` に pin 済み。layout は `javascript_importmap_tags 'hotwire'` で読み込み済み。npm dependency は削除済み。 |
| `@hotwired/stimulus` | `app/javascript/controllers/*` | `stimulus-rails` 標準構成に寄せる。 |
| `@hotwired/stimulus-loading` | importmap 移行後の controller loading | importmap 導入時に `eagerLoadControllersFrom("controllers", application)` へ置換する。 |

## Frequently Used Runtime Dependencies

| package | usage count | main files | migration note |
| --- | ---: | --- | --- |
| `@rails/request.js` | 22 | reactions, watches, bookmarks, sorting, tags | npm と同じ `0.0.12` を `vendor/javascript/importmap-rails-request.js` に pin 済み。 |
| `sortablejs` | 6 | category/course/FAQ/survey sorting | npm と同じ `1.15.0` を `vendor/javascript/importmap-sortablejs.js` に pin 済み。 |
| `choices.js` | 3 | `book-select.js`, `choices-ui.js`, `practice-filter-dropdown.js` | npm と同じ `10.1.0` を `vendor/javascript/importmap-choices.js` に pin 済み。CSS が必要なら asset 側の確認が必要。 |
| `dayjs` | 3 | `bootcamp.js`, notifications, current datetime | npm と同じ `1.10.4` を `vendor/javascript/importmap-dayjs.js` に pin 済み。locale/plugin import を含めて切替時に確認する。 |
| `sweetalert2` | 2 | toast/task-list initializer | npm と同じ `11.1.5` を `vendor/javascript/importmap-sweetalert2.js` に pin 済み。 |
| `@yaireo/tagify` | 2 | `tag.js`, `tags-input.js` | `lazy-tagify.js` 経由の dynamic import へ集約済み。importmap 化時は JS pin + CSS asset 化が必要。 |
| `autosize` | 2 | textarea/comment initialization | npm と同じ `4.0.2` を `vendor/javascript/importmap-autosize.js` に pin 済み。 |
| `escape-html` | 2 | textarea autocomplete | npm と同じ `1.0.3` を `vendor/javascript/importmap-escape-html.js` に pin 済み。 |
| `escape-string-regexp` | 2 | textarea autocomplete | npm と同じ `2.0.0` を `vendor/javascript/importmap-escape-string-regexp.js` に pin 済み。 |
| `hotkeys-js` | 1 | shortcut keys | npm と同じ `3.3.5` を `vendor/javascript/importmap-hotkeys-js.js` に pin 済み。 |

## Markdown And Code Highlighting

| package | usage | migration note |
| --- | --- | --- |
| `markdown-it` | Markdown preview and textarea initialization | plugin 群とまとめて pin する必要がある。 |
| `markdown-it-anchor` | headings | pin 候補。 |
| `markdown-it-container` | message/details/speak containers | pin 候補。 |
| `markdown-it-container-figure` | figure container | pin 候補。 |
| `markdown-it-emoji` | emoji data import including `lib/data/full.json` | JSON import が importmap で問題になりやすい。個別確認が必要。 |
| `markdown-it-link-attributes` | link attributes | pin 候補。 |
| `markdown-it-purifier` | Webpack alias to browser build | 現在 Webpack alias あり。importmap では browser build を明示 pin する。 |
| `markdown-it-regexp` | mention/user-icon/video plugins | pin 候補。 |
| `markdown-it-task-lists` | task lists | pin 候補。 |
| `prismjs` | code highlighting | component imports が多い。vendor 化または明示 pin が必要。 |

### Heavy Dependency Split Plan

Markdown/Prism/Ace は、importmap 化より前に読み込み境界を分けておく。

- Markdown viewer: `.js-markdown-view` の読み取り専用レンダリングを担当する。`markdown-it` 本体、Markdown plugin 群、`prismjs`、`prism-languages.js` をここへ集約する。
- Markdown editor: `.js-markdown` / コメント欄の編集機能を担当する。`textarea-markdown`、`tributejs`、emoji autocomplete、画像アップロード、preview を含むため viewer より後に移行する。
- Markdown lazy loading: `lazy-markdown.js` 経由の dynamic import へ集約済み。Markdown/Prism/editor 依存は `application` entrypoint から外れ、必要な画面で遅延 chunk として読み込まれる。
- Prism: component import は順序依存で global `Prism` を拡張するため、importmap では個別 pin よりも core + 使用 language をまとめた vendor file にする方が安全。言語一覧は `prism-languages.js` に集約したままにする。
- Ace: coding test 画面専用。Shakapacker の別 pack に分離済み。`ace-builds/webpack-resolver` は削除済みで、Ace の構文チェック worker は無効化済み。importmap/vendor 化する場合は `ace.js`、`mode-javascript.js`、`mode-ruby.js`、`theme-github.js` だけを配信する。

## Higher-Risk Runtime Dependencies

| package | usage | risk |
| --- | --- | --- |
| `ace-builds` | `coding-test.js` imports Ace, JavaScript/Ruby modes, GitHub theme | coding test 専用 pack へ分離済み。`ace-builds/webpack-resolver` は削除済み。importmap 化時は vendor 配信に切り替える。 |
| `chart.js`, `chartjs-plugin-annotation`, `chartjs-plugin-datalabels` | `survey_result_chart.js` | ESM pin は可能性あり。plugin 登録順と bundle size を確認する。 |
| `heic2any` | `fileinput.js` | browser-only 依存。importmap で動くか個別検証する。 |
| `@notus.sh/cocooned` | `packs/application.js` | Rails nested form 用。importmap pin 可能か確認が必要。 |
| `tributejs`, `textarea-markdown` | textarea initializer | editor 周りの中核。pin 後に system test が必要。 |

## Local Alias Imports To Rewrite Or Pin

Webpack の `app/javascript` 解決に依存していた local alias import は relative import へ統一済み。importmap への entrypoint 切替時は、必要な local module を Sprockets へ公開する範囲を追加する。

| alias | examples | migration note |
| --- | --- | --- |
| `csrf` | `import CSRF from './csrf.js'` | relative import 化済み。 |
| `textarea-initializer` | comments, reports, mentor memo | relative import 化済み。 |
| `markdown-initializer` | comments, reports, markdown | relative import 化済み。 |
| `bootcamp` | coding/micro reports | relative import 化済み。 |
| `vanillaToast.js` | toast usage | `.js` 付き relative import に統一済み。 |
| markdown plugin local modules | `markdown-it-option`, `markdown-it-user-icon` など | relative import 化済み。 |

## Webpack/Shakapacker-Only Dependencies

完全移行後に削除候補。

- `shakapacker`
- `webpack`
- `webpack-cli`
- `webpack-dev-server`
- `@webpack-cli/serve`
- `webpack-assets-manifest`
- `webpack-merge`
- `webpack-sources`
- `babel-loader`
- `@babel/core`
- `@babel/preset-env`
- `@babel/plugin-*`
- `babel-plugin-*`
- `compression-webpack-plugin`
- `css-loader`
- `file-loader`
- `mini-css-extract-plugin`
- `style-loader`
- `terser-webpack-plugin`
- `@types/webpack`
- `@types/babel__core`
- `buffer`
- `process`
- `util`

## Unused Runtime Dependency Candidates

`app/javascript` と `config` の import/require では見つからなかったもの。削除前に `package-lock.json` の transitive dependency ではなく direct dependency として必要か確認する。

- `dompurify`
- `prettier-config-standard`

## Suggested Order

1. Local alias imports を relative import へ統一する。（完了）
2. importmap の足場と Simple runtime dependencies の pin を追加する。（完了）
3. Turbo を importmap entrypoint で読み込む。（完了）
4. Importmap vulnerability audit を CI に戻す。（完了）
5. importmap 導入時に Stimulus controller loading を `stimulus-loading` 方式へ置換する。
6. Tagify/Prism/Markdown/Ace の asset・CSS・worker 問題を個別に処理する。Ace は coding test 専用 pack へ分離済み。
7. Shakapacker/Webpack/Babel 依存と設定を削除する。
