# frozen_string_literal: true

class Practice < ActiveRecord::Base
  include Searchable

  has_many :learnings
  has_and_belongs_to_many :reports
  has_many :started_learnings,
    -> { where(status_cd: 0) },
    class_name: "Learning"
  has_many :completed_learnings,
    -> { where(status_cd: 1) },
    class_name: "Learning"
  has_many :started_users,
    through: :started_learnings,
    source: :user
  has_many :completed_users,
    through: :completed_learnings,
    source: :user
  has_many :products
  has_many :questions
  belongs_to :category
  acts_as_list scope: :category

  validates :title, presence: true
  validates :description, presence: true
  validates :goal, presence: true

  def status(user)
    learnings = Learning.where(
      user_id: user.id,
      practice_id: id
    )
    if learnings.blank?
      :not_complete
    else
      learnings.first.status
    end
  end

  def completed?(user)
    status_cds = Learning.statuses.values_at("complete")
    Learning.exists?(
      user:        user,
      practice_id: id,
      status_cd:   status_cds
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
