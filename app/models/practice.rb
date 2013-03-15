class Practice < ActiveRecord::Base
  as_enum :aim, [:everyone, :programmer, :designer]
  has_many :learnings

  validates :title, presence: true
  validates :description, presence: true

  scope :for_programmer, ->{ where.not(aim_cd: Practice.designer) }
  scope :for_designer, ->{ where.not(aim_cd: Practice.programmer) }
end
