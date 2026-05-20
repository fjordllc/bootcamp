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
| `choices.js` | 3 | `book-select.js`, `choices-ui.js`, `practice-filter-dropdown.js` | JS は pin 候補。CSS が必要なら asset 側の確認が必要。 |
| `dayjs` | 3 | `bootcamp.js`, notifications, current datetime | locale/plugin import を含めて pin する。 |
| `sweetalert2` | 2 | toast/task-list initializer | npm と同じ `11.1.5` を `vendor/javascript/importmap-sweetalert2.js` に pin 済み。 |
| `@yaireo/tagify` | 2 | `tag.js`, `tags-input.js` | CSS import が Webpack 前提。JS pin + CSS を asset 化する必要がある。 |
| `autosize` | 2 | textarea/comment initialization | npm と同じ `4.0.2` を `vendor/javascript/importmap-autosize.js` に pin 済み。 |

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

## Higher-Risk Runtime Dependencies

| package | usage | risk |
| --- | --- | --- |
| `ace-builds` | `coding-test.js` imports webpack resolver, modes, theme, workers | `ace-builds/webpack-resolver` は Webpack 前提。worker 配信方法を設計する必要がある。 |
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
6. Tagify/Prism/Markdown/Ace の asset・CSS・worker 問題を個別に処理する。
7. Shakapacker/Webpack/Babel 依存と設定を削除する。
