# frozen_string_literal: true

# ユーザーのログイン名に関する責務をまとめたもの。
module UserLoginName
  extend ActiveSupport::Concern

  included do
    validates :login_name, exclusion: { in: User::RESERVED_LOGIN_NAMES, message: 'に使用できない文字列が含まれています' }
    validates :login_name, length: { minimum: 3, message: 'は3文字以上にしてください。' }

    with_options if: -> { %i[create update].include? validation_context } do
      validates :login_name, presence: true, uniqueness: true,
                             format: {
                               with: /\A[a-z\d](?:[a-z\d]|-(?=[a-z\d]))*\z/i,
                               message: 'は半角英数字と-（ハイフン）のみが使用できます 先頭と最後にハイフンを使用することはできません ハイフンを連続して使用することはできません'
                             }
    end
  end
end
