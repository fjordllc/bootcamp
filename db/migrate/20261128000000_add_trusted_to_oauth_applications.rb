# frozen_string_literal: true

class AddTrustedToOauthApplications < ActiveRecord::Migration[8.1]
  def change
    # 自社のアプリ(FJORD Classroom、FJORD Live レッスンなど)だけ true にする。許可の確認画面を省く。
    add_column :oauth_applications, :trusted, :boolean, default: false, null: false
  end
end
