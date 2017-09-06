class Practice < ActiveRecord::Base
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
  belongs_to :category
  acts_as_list scope: :category
  has_many :task_requests

  validates :title, presence: true
  validates :description, presence: true
  validates :goal, presence: true
  validates :assignment, inclusion: { in: [true, false] }

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

  def not_completed?(user)
    status_cds = Learning.statuses.values_at("complete")

    !Learning.exists?(
      user:        user,
      practice_id: id,
      status_cd:   status_cds
    )
  end

  def completed?(user)
    status_cds = Learning.statuses.values_at("complete")

    Learning.exists?(
      user:        user,
      practice_id: id,
      status_cd:   status_cds
    )
  end

  def task_checking?(user)
    status_cds = Learning.statuses.values_at("task_checking")

    Learning.exists?(
      user:        user,
      practice_id: id,
      status_cd:   status_cds
    )
  end

  def not_complete_or_checking?(user)
    !(self.completed?(user) || self.task_checking?(user))
  end

  def exists_learning?(user)
    Learning.exists?(
      user:        user,
      practice_id: id
    )
  end

  def task_requested?(user)
    TaskRequest.find_by(
      user_id: user.id,
      practice_id: id
    )
  end

  def with_task_checking(user)
    learning = Learning.find_or_create_by(
      user_id: user.id,
      practice_id: id
    )
    learning.update!(status: :task_checking)
  end

  def all_text
    [title, description, goal].join("\n")
  end
end
