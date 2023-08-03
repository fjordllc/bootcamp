# frozen_string_literal: true

class CreateBuzz < ActiveRecord::Migration[6.1]
  def up
    Buzz.create(body: 'インターネットで見つけたフィヨルドブートキャンプに関連する記事、フィヨルドブートキャンプに言及いただいた記事を集めています。このページに載せて欲しい記事、掲載NGな記事がありましたら[お問い合わせフォーム](https://bootcamp.fjord.jp/inquiry/new)からご連絡ください。')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
