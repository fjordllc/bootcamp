# frozen_string_literal: true

class Practice < ActiveRecord::Base
  include Searchable

  has_many :learnings
  has_and_belongs_to_many :reports
  has_many :started_learnings,
    -> { where(status: "started") },
    class_name: "Learning"
  has_many :completed_learnings,
    -> { where(status: "complete") },
    class_name: "Learning"
  has_many :started_users,
    through: :started_learnings,
    source: :user
  has_many :completed_users,
    through: :completed_learnings,
    source: :user
  has_many :started_students,
    -> { students },
    through: :started_learnings,
    source: :user
  has_many :products
  has_many :questions
  belongs_to :category
  acts_as_list scope: :category

  validates :title, presence: true
  validates :description, presence: true
  validates :goal, presence: true

  scope :category_order, -> { includes(:category).order("categories.position").order(:position) }

  def status(user)
    learnings = Learning.where(
      user_id: user.id,
      practice_id: id
    )
    if learnings.blank?
      "not_complete"
    else
      learnings.first.status
    end
  end

  def status_by_learnings(learnings)
    learning = learnings.detect { |lerning| id == lerning.practice_id }
    learning&.status || "not_complete"
  end

  def completed?(user)
    Learning.exists?(
      user:        user,
      practice_id: id,
      status:      Learning.statuses[:complete]
    )
  end

  def not_completed?(user)
    !completed?(user)
  end

  def exists_learning?(user)
    Learning.exists?(
      user:        user,
      practice_id: id
    )
  end

  def learning(user)
    learnings.find_by(user: user)
  end

  def all_text
    [title, description, goal].join("\n")
  end

  def product(user)
    products.find_by(user: user)
  end
end
