# frozen_string_literal: true

# 自社のアプリ(FJORD Live レッスン、FJORD Classroom)を trusted にして、許可の確認画面を省く。
# uid は各サービスが認可の URL に載せている client_id(公開されている値)。
class TrustFjordOauthApplications < ActiveRecord::Migration[8.1]
  FJORD_APP_UIDS = [
    'k6bbTCcjB8bwSY2s9_Htkspx8cLoz6Nay4llfbTtMBo', # FJORD Live レッスン(liveclass.fjord.jp)
    'WeJAH7N_GO8FLAsZ_5GYHNDB7A9t1x4ob5D25bOa0Dc'  # FJORD Classroom(classroom.fjord.jp)
  ].freeze

  def up
    Doorkeeper::Application.where(uid: FJORD_APP_UIDS).update_all(trusted: true) # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    Doorkeeper::Application.where(uid: FJORD_APP_UIDS).update_all(trusted: false) # rubocop:disable Rails/SkipsModelValidations
  end
end
