# frozen_string_literal: true

class Practice < ApplicationRecord
  include Watchable
  include Searchable

  has_many :learnings, dependent: :destroy
  has_and_belongs_to_many :reports # rubocop:disable Rails/HasAndBelongsToMany
  has_many :started_learnings,
           -> { where(status: 'started') },
           class_name: 'Learning',
           inverse_of: 'practice',
           dependent: nil
  has_many :completed_learnings,
           -> { where(status: 'complete') },
           class_name: 'Learning',
           inverse_of: 'practice',
           dependent: nil
  has_many :started_users,
           through: :started_learnings,
           source: :user
  has_many :completed_users,
           through: :completed_learnings,
           source: :user
  has_many :started_students,
           -> { students_and_trainees },
           through: :started_learnings,
           source: :user
  has_many :products, dependent: :destroy
  has_many :questions, dependent: :nullify
  has_many :pages, dependent: :nullify
  has_one :learning_minute_statistic, dependent: :destroy
  belongs_to :last_updated_user, class_name: 'User', optional: true

  has_many :categories_practices, dependent: :destroy
  has_many :categories, through: :categories_practices
  has_many :reference_books, inverse_of: :practice, dependent: :destroy
  accepts_nested_attributes_for :reference_books, reject_if: :all_blank, allow_destroy: true

  validates :title, presence: true
  validates :description, presence: true
  validates :goal, presence: true
  validates :categories, presence: true

  columns_for_keyword_search :title, :description, :goal

  class << self
    def save_learning_minute_statistics
      Practice.all.find_each do |practice|
        practice_id = practice.id
        learning_minute_list = practice.learning_minute_per_user

        if learning_minute_list.sum.positive?
          average_learning_minute = practice.average_learning_minute(learning_minute_list)
          median_learning_minute = practice.median_learning_minute(learning_minute_list)
          practice.save_statistic(practice_id, average_learning_minute, median_learning_minute)
        end
      end
    end
  end

  def status(user)
    learnings = Learning.where(
      user_id: user.id,
      practice_id: id
    )
    if learnings.blank?
      'unstarted'
    else
      learnings.first.status
    end
  end

  def status_by_learnings(learnings)
    learning = learnings.detect { |lerning| id == lerning.practice_id }
    learning&.status || 'unstarted'
  end

  def completed?(user)
    Learning.exists?(
      user: user,
      practice_id: id,
      status: Learning.statuses[:complete]
    )
  end

  def exists_learning?(user)
    Learning.exists?(
      user: user,
      practice_id: id
    )
  end

  def learning(user)
    learnings.find_by(user: user)
  end

  def all_text
    [title, description, goal].join("\n")
  end

  def body
    [description, goal].join("\n")
  end

  def product(user)
    products.find_by(user: user)
  end

  def learning_minute_per_user
    user_id = 0
    learning_minute_list = []

    reports.not_wip.order('user_id asc').each do |report|
      if user_id == report.user_id
        sum_same_user = learning_minute_list.last + total_learning_minute(report)
        learning_minute_list.pop
        learning_minute_list << sum_same_user
      else
        learning_minute_list << total_learning_minute(report)
        user_id = report.user_id
      end
    end
    learning_minute_list.sort!
  end

  def average_learning_minute(learning_minute_list)
    learning_minute_list.sum.fdiv(learning_minute_list.size)
  end

  def median_learning_minute(minute_list)
    center_index = ((minute_list.size - 1) / 2).floor
    if minute_list.size.even?
      (minute_list[center_index] + minute_list[center_index + 1]) / 2
    else
      (minute_list[center_index])
    end
  end

  def save_statistic(practice_id, average, median)
    learning_minute_statistic = LearningMinuteStatistic.find_or_initialize_by(practice_id: practice_id)
    learning_minute_statistic.update(
      average: average,
      median: median
    )
  end

  def category(course)
    Category.category(practice: self, course: course) || categories.first || Category.first
  end

  private

  def total_learning_minute(report)
    total_time = report.learning_times.inject(0) do |sum, learning_time|
      sum + learning_time.diff
    end

    total_minute = (total_time / 60)
    if report.practices.size > 1
      average_minute_per_practice(total_minute, report.practices.size)
    else
      total_minute
    end
  end

  def average_minute_per_practice(minute, size)
    minute / size
  end
end
