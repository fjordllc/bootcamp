# frozen_string_literal: true

class Talk < ApplicationRecord
  include Commentable

  belongs_to :user

  scope :unreplied, -> { where(unreplied: true) }
  scope :required_list_data, lambda { |target|
    eager_load(user: [:company, { avatar_attachment: :blob }])
      .merge(User.users_role(target))
  }
  scope :search_by_user_keywords, lambda { |search_word|
    where(<<~SQL, search_word: "%#{search_word}%")
      "users"."login_name" ILIKE :search_word
      OR "users"."name" ILIKE :search_word
      OR "users"."name_kana" ILIKE :search_word
      OR "users"."discord_account" ILIKE :search_word
    SQL
  }
end
