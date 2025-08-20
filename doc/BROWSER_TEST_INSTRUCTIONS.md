# ブラウザテスト手順書

## 事前準備
1. 開発サーバーが起動していることを確認: `http://localhost:3000`
2. ブラウザで開発者ツールを開く（F12キー）

## テスト手順

### 1. ログイン
1. `http://localhost:3000` にアクセス
2. ログインフォームで以下の情報を入力:
   - ユーザー名: `komagata`
   - パスワード: `testtest`
3. ログイン

### 2. 通常の検索ページテスト
1. `http://localhost:3000/searchables?word=Rails` にアクセス
2. 開発者ツールで以下を確認:
   - ユーザー名の下に不適切な大きなスペースがないか
   - `.card-list-item-meta__items` 要素のCSSプロパティ:
     - `margin-top: 0px`
     - `margin-bottom: 0px`

### 3. スマート検索ページテスト
1. `http://localhost:3000/smart_searchables?word=Rails` にアクセス
2. 同様にスペース状況とCSS値を確認

### 4. 開発者ツールでのCSS確認
1. Elements タブを開く
2. `.card-list-item-meta__items` クラスの要素を選択
3. Computed タブまたは Styles タブで以下を確認:
   - `margin-top`
   - `margin-bottom`
   - `padding-top`
   - `padding-bottom`
   - `gap`

### 5. 自動検証スクリプト実行
1. Console タブを開く
2. `test_browser_validation.js` の内容をコピー&ペースト
3. 実行して結果を確認

## 期待する結果

### ✅ 修正が成功している場合
- ユーザー名の下に大きなスペースがない
- `.card-list-item-meta__items` で:
  - `margin-top: 0px`
  - `margin-bottom: 0px`
- コンソールで「すべての .card-list-item-meta__items で margin が適切に 0 に設定されています」と表示

### ❌ 問題がまだある場合
- ユーザー名の下に不適切なスペースが残っている
- CSS値が期待値と異なる
- コンソールで問題のある要素が報告される

## トラブルシューティング

### CSS が反映されていない場合
1. ブラウザのキャッシュをクリア (Ctrl+Shift+R または Cmd+Shift+R)
2. 開発サーバーを再起動
3. Webpackが正しくコンパイルされているか確認

### スマート検索ページが見つからない場合
- ルートが正しく設定されているか確認
- `config/routes/api.rb` の設定を確認

### 検索結果が表示されない場合
- データベースに適切なデータがあるか確認
- エンベディングが生成されているか確認