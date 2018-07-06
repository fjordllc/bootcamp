class Report < ActiveRecord::Base
  include Commentable
  include Checkable

  has_many :footprints
  has_many :learning_times, dependent: :destroy, inverse_of: :report
  accepts_nested_attributes_for :learning_times, reject_if: :all_blank, allow_destroy: true
  has_and_belongs_to_many :practices
  belongs_to :user, touch: true

  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
  validates :user, presence: true
  validates :reported_at, presence: true, uniqueness: { scope: :user }

  def previous
    Report.where("created_at < ?", self.created_at).order("created_at DESC").first
  end

  def next
    Report.where("created_at > ?", self.created_at).order("created_at ASC").first
  end
  
end
