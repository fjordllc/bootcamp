# Hotwire Dependency Audit

React 削除後に Shakapacker/Webpack から importmap + Hotwire へ完全移行するための npm 依存棚卸し。

## Hotwire Core

| package | usage | migration note |
| --- | --- | --- |
| `@hotwired/turbo-rails` | `app/javascript/packs/application.js` | importmap で `@hotwired/turbo-rails` を pin する。 |
| `@hotwired/stimulus` | `app/javascript/controllers/*` | `stimulus-rails` 標準構成に寄せる。 |
| `@hotwired/stimulus-webpack-helpers` | `app/javascript/controllers/index.js` | Webpack の `require.context` 前提。importmap 移行時に削除し、`stimulus-loading` 方式へ置換する。 |

## Frequently Used Runtime Dependencies

| package | usage count | main files | migration note |
| --- | ---: | --- | --- |
| `@rails/request.js` | 22 | reactions, watches, bookmarks, sorting, tags | importmap pin しやすい。 |
| `sortablejs` | 6 | category/course/FAQ/survey sorting | importmap pin 候補。 |
| `choices.js` | 3 | `book-select.js`, `choices-ui.js`, `practice-filter-dropdown.js` | JS は pin 候補。CSS が必要なら asset 側の確認が必要。 |
| `dayjs` | 3 | `bootcamp.js`, notifications, current datetime | locale/plugin import を含めて pin する。 |
| `sweetalert2` | 2 | toast/task-list initializer | importmap pin 候補。 |
| `@yaireo/tagify` | 2 | `tag.js`, `tags-input.js` | CSS import が Webpack 前提。JS pin + CSS を asset 化する必要がある。 |
| `autosize` | 2 | textarea/comment initialization | importmap pin 候補。 |

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

Webpack の `app/javascript` 解決に依存している local alias import がある。

| alias | examples | migration note |
| --- | --- | --- |
| `csrf` | `import CSRF from 'csrf'` | relative import に直すか `pin "csrf", to: "csrf.js"` する。 |
| `textarea-initializer` | comments, reports, mentor memo | relative import または importmap pin。 |
| `markdown-initializer` | comments, reports, markdown | relative import または importmap pin。 |
| `bootcamp` | coding/micro reports | relative import または importmap pin。 |
| `vanillaToast` / `vanillaToast.js` | toast usage | 表記を統一して pin/relative 化する。 |
| markdown plugin local modules | `markdown-it-option`, `markdown-it-user-icon` など | npm package と local module が混在するため命名衝突に注意。 |

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

- `@codemirror/basic-setup`
- `clsx`
- `dompurify`
- `jp-postal`
- `js-yaml`
- `lodash`
- `lodash.template`
- `mem`
- `query-string`
- `set-value`
- `prettier-config-standard`

## Suggested Order

1. Local alias imports を relative import か importmap pin に統一する。
2. `@hotwired/stimulus-webpack-helpers` を `stimulus-loading` 方式へ置換する。
3. Simple runtime dependencies を importmap pin して動作確認する。
4. Tagify/Prism/Markdown/Ace の asset・CSS・worker 問題を個別に処理する。
5. Shakapacker/Webpack/Babel 依存と設定を削除する。
