# frozen_string_literal: true

# 自社のアプリ(FJORD Live レッスン、FJORD Classroom)を trusted にして、許可の確認画面を省く。
# uid は各サービスが認可の URL に載せている client_id(公開されている値)。
class TrustFjordOauthApplications < ActiveRecord::Migration[8.1]
  FJORD_APP_UIDS = [
    'k6bbTCcjB8bwSY2s9_Htkspx8cLoz6Nay4llfbTtMBo', # FJORD Live レッスン(liveclass.fjord.jp)
    'WeJAH7N_GO8FLAsZ_5GYHNDB7A9t1x4ob5D25bOa0Dc'  # FJORD Classroom(classroom.fjord.jp)
  ].freeze

  def up
    execute <<~SQL.squish
      UPDATE oauth_applications SET trusted = TRUE
      WHERE uid IN (#{FJORD_APP_UIDS.map { |uid| connection.quote(uid) }.join(', ')})
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE oauth_applications SET trusted = FALSE
      WHERE uid IN (#{FJORD_APP_UIDS.map { |uid| connection.quote(uid) }.join(', ')})
    SQL
  end
end
