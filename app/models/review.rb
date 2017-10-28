class Review < ApplicationRecord
  belongs_to :user
  belongs_to :submission

  default_scope -> { order(created_at: :desc) }

  validates :user, presence: true
  validates :submission, presence: true
  validates :message, presence: true, length: { maximum: 2000 }

  def is_edited?
    !(created_at == updated_at)
  end
end
