class Artifact < ApplicationRecord
  belongs_to :user
  belongs_to :practice

  validates :user_id, presence: true, uniqueness: { scope: :practice_id }
  validates :practice_id, presence: true, uniqueness: { scope: :user_id }
  validates :content, presence: true, length: { minimum: 5, maximum: 2000 }

  scope :completed, -> { where(done: true) }
  scope :confirmation, -> { where(done: false) }

  def to_done
    self.update(done: true)
  end
end
