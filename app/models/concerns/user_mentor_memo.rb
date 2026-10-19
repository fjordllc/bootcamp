# frozen_string_literal: true

# ユーザーに対するメンターメモに関する責務をまとめたもの。
module UserMentorMemo
  extend ActiveSupport::Concern

  included do
    has_many :mentor_memos, dependent: :destroy
  end
end
