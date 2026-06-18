# bootcamp 完全リファクタリング計画

作成日: 2026-06-10

## 現状サマリー

13年運用の Rails 8.1 / Ruby 3.4 アプリ。基盤(Rails/Ruby/importmap/Solid Queue)は最新化済みで、主な負債は「成長に伴う設計の歪み」。

主要な負債:

- **User モデルが God Object**(`app/models/user.rb`、約1,000行、アソシエーション60超、enum 6個)
- **通知システムの細分化**(Notifier系クラス32個 + Destroyer 3個、`activity_notifier.rb` 501行)
- **巨大コントローラ**(`app/controllers/reports_controller.rb` 215行25メソッド、`app/controllers/users_controller.rb` 253行)
- **フロントJSの無秩序**(`app/javascript` に手続き型JSが約130ファイル、Stimulusコントローラは実質1個、`rails_ujs_compat.js` という自前UJS互換層)
- **CSSの肥大**(atoms 310ファイル、`modules/_github.css` 2万行、Tailwindとカスタム CSSの二重管理)
- **巨大ビュー**(`welcome/training.html.slim` 1,096行ほか、ヘルパー肥大)
- 小物:
  - `config/routes.rb:69` の `only: %i(index show show)` 重複
  - `config/initializers/new_framework_defaults_{6_1,7_0,7_1,7_2}.rb` の残骸
  - `config/secrets.yml` の Stripe テスト鍵ハードコード
  - 空の `app/javascript/serviceWorker.js`

system test 311本 + 8シャードCIという強力な安全網があるため、**振る舞いを変えないリファクタリングを小さなPRで刻む**戦略を取る。

---

## フェーズ0: 即効クリーンアップ(1〜2日、リスクほぼゼロ)

リファクタの地ならし。すべて独立した小PRで。

1. `config/routes.rb:69` の `show show` 重複修正
2. `config/initializers/new_framework_defaults_{6_1,7_0,7_1,7_2}.rb` 削除(`load_defaults 7.2` 適用済みのため不要。ついでに `load_defaults 8.1` への引き上げを別PRで検討)
3. 空ファイル削除: `app/javascript/serviceWorker.js`
4. `config/secrets.yml` の Stripe テスト鍵を環境変数/credentials へ移行
5. `lib/tasks/bootcamp.rake` の `copy_practices`(一回限りタスク、200行超)の廃止判定・削除
6. ツール更新: ESLint 8→9、Prettier 2→3、Playwright 更新
7. `user.rb:2019` の FIXME、`regular_event.rb` の TODO を Issue 化して棚卸し

**検証**: `bin/lint` + CI全パス。

## フェーズ1: 計測と検出の仕組み導入(2〜3日)

「無駄」を推測でなく機械的に特定する。

1. 未使用コード検出: `debride` / coverage計測(本番で `Coverband` 等)で未使用メソッド・アクション候補をリスト化
2. 未使用CSS検出: ビュー全体に対するクラス名 grep スクリプトで atoms 310ファイルの使用状況を棚卸し
3. 未参照パーシャル・ヘルパーメソッドの機械的リストアップ
4. 結果を `docs/refactoring/` に死蔵コード台帳として記録(以降のフェーズの作業リストになる)

## フェーズ2: 死蔵コードの削除(1〜2週間)

フェーズ1の台帳に基づき削除のみ行う。**削除はリファクタより安全で効果が大きいので先にやる。**

- 未使用ヘルパーメソッド、未参照パーシャル、未使用JSファイル、未使用CSS(atoms/blocks)
- `config/importmap.rb` の整理: 実際に使われていない markdown-it プラグイン・Prism 言語パッケージ(26個ピン)・低レベルポリフィル(buffer, readable-stream 等)の削減
- 1PR = 1カテゴリで刻む。各PRで system test 全パスを確認

## フェーズ3: コントローラ/サービス層のリファクタ(2〜4週間)

1. **ReportsController**: `canonicalize_learning_times` 等のビジネスロジックを既存の `app/interactors/` パターンに合わせてサービス化(Interactor が既に5個あるので新パターンは導入しない)
2. **UsersController**: 統計計算(StudyStreak, Grass)をクエリオブジェクト(`app/queries/` 既存8個のパターン)へ
3. **API::Users::SupportContextsController**(162行)の分解
4. カスタムアクション(`comment_by_pjord` 等)の REST リソース化を機会主義的に
5. Controller Concerns で認証・共通処理の重複を吸収

## フェーズ4: 通知システムの統合(2〜3週間)

最も削減効果が大きい領域(推定20〜30%削減)。

1. 32個の Notifier を共通基底クラス + 宛先解決(recipient resolver)の合成に再設計
   - `product_notifier_for_*` 4種 → 1クラス + 宛先戦略
   - `pair_work_*_notifier` 5種 → イベント種別パラメータ化
2. `*_notification_destroyer` 3種をテンプレートメソッドで共通化
3. `activity_notifier.rb`(501行)の分解
4. 既存の通知 system test を回しながら1グループずつ移行

## フェーズ5: User モデルの分解(3〜4週間、最難関)

一気にやらず、**振る舞いの引っ越し**を段階的に。

1. まず関心ごとに concern 化して責務の境界線を可視化(既存の `app/models/concerns/` 11個のパターンに準拠): `User::Learning`, `User::Social`, `User::Billing`, `User::Retirement` 等
2. enum・定数・スコープを各 concern へ移動
3. 通知判定ロジック(FIXME 箇所含む)をフェーズ4の成果物に接続
4. 必要ならその後に委譲オブジェクト(`user.learning.〜`)へ昇格。テーブル分割はやらない(リスク過大)

## フェーズ6: フロントエンドの正規化(3〜4週間、バックエンドと並行可)

1. **Stimulus 移行**: 約130個の手続き型JSを壊れやすいものから順に Stimulus コントローラ化。bookmark 系3ファイル(`bookmarks.js` / `bookmark-button.js` / `dashboard-bookmarks.js`)の統合を最初の見本PRに
2. **rails_ujs_compat.js の撤廃**: `data-method`/`data-confirm` 利用箇所を Turbo(`data-turbo-method`/`data-turbo-confirm`)へ置換して削除
3. **巨大ビュー分割**: `welcome/training.html.slim`(1,096行)等のLP系をパーシャル/ViewComponent 化
4. **ヘルパー→ViewComponent**: `users_helper`, `products_helper` 等の表示ロジックを既存52コンポーネントのパターンへ
5. **CSS戦略の決定**: Tailwind に寄せるか独自 atoms 設計を維持するかをここで決定(全面 Tailwind 化は別プロジェクト級。推奨は「atoms を維持しつつ未使用削除 + `_github.css` 2万行の出自調査・削減」)

## フェーズ7: 仕上げと再発防止(1週間)

1. Traceroute/debride/CSS棚卸しスクリプトを CI に組み込み、死蔵コードの再蓄積を防止
2. CLAUDE.md / docs に「層の使い分け規約」(Interactor vs Query vs Concern vs ViewComponent、JS は Stimulus 必須等)を明文化
3. RuboCop 除外(`app/views`, `config`)の縮小検討
4. controller/integration test の薄い箇所(controller test 2本のみ)を API 中心に補強

---

## 進め方の原則

- **1 PR = 1関心事、常にグリーン**。system test 311本が安全網
- 順序は 削除(0〜2)→ 構造改善(3〜5)→ フロント(6)→ 防止(7)。フェーズ6はバックエンド系と並行可能
- 期間目安: 専任1名で3〜4ヶ月、片手間なら6ヶ月強
- 各フェーズ完了時に台帳(`docs/refactoring/`)を更新し、次フェーズの対象を確定
