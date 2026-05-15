# frozen_string_literal: true

class Talk < ApplicationRecord
  include Commentable
  include Bookmarkable
  include Searchable

  belongs_to :user

  paginates_per 20

  scope :action_uncompleted, -> { where(action_completed: false) }

  # 検索での可視性チェック: 管理者または自分の相談のみ表示
  def visible_to_user?(user)
    user&.admin? || user_id == user&.id
  end
end
