class Practice < ActiveRecord::Base
  include RankedModel
  ranks :row_order
  as_enum :target, [:everyone, :programmer, :designer]
  has_many :learnings

  has_many :completed_learnings,
    -> { where(status_cd: 1) },
    class_name: 'Learning'
  has_many :completed_users,
    through: :completed_learnings,
    source: :user

  validates :title, presence: true
  validates :description, presence: true
  validates :goal, presence: true
  validates :target, presence: true

  scope :for_programmer, ->{ where.not(target_cd: Practice.designer) }
  scope :for_designer, ->{ where.not(target_cd: Practice.programmer) }
end
