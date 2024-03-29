json.external_entries @external_entries, partial: 'api/external_entries/external_entry', as: :external_entry
# json.total_pages @external_entries.total_pages
# 「プルリク #7447」と同様に、/api/external_entries_controller.rb でインスタンス変数を消した場合、
# http://localhost:3000/api/external_entries.json に接続した時に、上記のコメントアウト行でエラーが出る
# エラーを回避するには「行を削除」か「/api/talks/index.json.jbuilder のような書き方に変更する」

# にしたつ#TODO - このファイルは残しておく（参考：プルリク #7447）
