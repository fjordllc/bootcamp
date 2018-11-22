# frozen_string_literal: true

class Report < ActiveRecord::Base
  include Commentable
  include Checkable
  include Footprintable

  has_many :learning_times, dependent: :destroy, inverse_of: :report
  accepts_nested_attributes_for :learning_times, reject_if: :all_blank, allow_destroy: true
  has_and_belongs_to_many :practices
  belongs_to :user, touch: true

  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
  validates :user, presence: true
  validates :reported_on, presence: true, uniqueness: { scope: :user }

  scope :default_order, -> { order(reported_on: :desc, user_id: :desc) }

  scope :unchecked, -> { where.not(id: Check.where(checkable_type: "Report").pluck(:checkable_id)) }

  def previous
    Report.where(user: user)
          .where("reported_on < ?", reported_on)
          .order(created_at: :desc)
          .first
  end

  def next
    Report.where(user: user)
          .where("reported_on > ?", reported_on)
          .order(:reported_on)
          .first
  end
end
