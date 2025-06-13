# frozen_string_literal: true

class Practice < ApplicationRecord
  include Watchable
  include Searchable

  has_many :learnings, dependent: :destroy
  has_and_belongs_to_many :reports # rubocop:disable Rails/HasAndBelongsToMany
  has_many :completed_learnings,
           -> { where(status: 'complete') },
           class_name: 'Learning',
           inverse_of: 'practice',
           dependent: nil
  has_many :started_or_submitted_learnings,
           -> { where(status: 'started').or(where(status: 'submitted')) },
           class_name: 'Learning',
           inverse_of: 'practice',
           dependent: nil
  has_many :started_or_submitted_students,
           -> { students_and_trainees },
           through: :started_or_submitted_learnings,
           source: :user
  has_many :skipped_users,
           through: :skipped_practices,
           source: :user
  has_many :skipped_practices, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :questions, dependent: :nullify
  has_many :pages,
           -> { order(updated_at: :desc, id: :desc) },
           dependent: :nullify,
           inverse_of: :practice
  has_many :practices_movies, dependent: :nullify
  has_many :movies, through: :practices_movies
  has_one :learning_minute_statistic, dependent: :destroy
  belongs_to :last_updated_user, class_name: 'User', optional: true

  has_many :categories_practices, dependent: :destroy
  has_many :categories, through: :categories_practices
  has_one_attached :ogp_image
  has_one_attached :completion_image

  has_many :practices_books, dependent: :destroy
  has_many :books, through: :practices_books
  accepts_nested_attributes_for :practices_books, reject_if: :all_blank, allow_destroy: true

  has_one :submission_answer, dependent: :destroy
  has_many :coding_tests, dependent: :nullify

  has_many :coding_test_submissions,
           through: :coding_tests,
           source: :coding_test_submissions

  # Practice copy relationships
  has_many :copied_practices, class_name: 'Practice', foreign_key: 'source_id', dependent: :nullify, inverse_of: :source_practice
  belongs_to :source_practice, class_name: 'Practice', foreign_key: 'source_id', optional: true, inverse_of: :copied_practices

  validates :title, presence: true
  validates :description, presence: true
  validates :goal, presence: true
  validates :categories, presence: true

  columns_for_keyword_search :title, :description, :goal

  scope :with_counts, lambda {
    select('practices.*,
           (SELECT COUNT(*) FROM products WHERE products.practice_id = practices.id) as products_count,
           (SELECT COUNT(*) FROM practices_reports WHERE practices_reports.practice_id = practices.id) as reports_count,
           (SELECT COUNT(*) FROM questions WHERE questions.practice_id = practices.id) as questions_count')
  }

  scope :for_mentor_index, lambda {
    with_counts
      .preload(:categories, :submission_answer)
      .order(:id)
  }

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

    def copied_practices_indexed_by_source_id(practice_ids)
      copied_from(practice_ids).index_by(&:source_id)
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
      user:,
      practice_id: id,
      status: Learning.statuses[:complete]
    )
  end

  def exists_learning?(user)
    Learning.exists?(
      user:,
      practice_id: id
    )
  end

  def learning(user)
    learnings.find_by(user:)
  end

  def all_text
    [title, description, goal].join("\n")
  end

  def body
    [description, goal].join("\n")
  end

  def product(user)
    products.find_by(user:)
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
    learning_minute_statistic = LearningMinuteStatistic.find_or_initialize_by(practice_id:)
    learning_minute_statistic.update(
      average:,
      median:
    )
  end

  def category(course)
    Category.category(practice: self, course:) || categories.first || Category.first
  end

  def tweet_url(practice_completion_url)
    completion_text = "プラクティス「#{title}」を修了しました🎉"
    # ref: https://developer.twitter.com/en/docs/twitter-for-websites/tweet-button/guides/web-intent
    tweet_param = URI.encode_www_form(text: completion_text, url: practice_completion_url, hashtags: 'fjordbootcamp')
    "https://twitter.com/intent/tweet?#{tweet_param}"
  end

  def include_must_read_books?
    return false if practices_books.empty?

    practices_books.any?(&:must_read)
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

  def convert_to_hour_minute(learning_minute_statistic)
    converted_hour = learning_minute_statistic / 60
    converted_minute = (learning_minute_statistic % 60).round
    if converted_minute.zero?
      "#{converted_hour}時間"
    else
      "#{converted_hour}時間#{converted_minute}分"
    end
  end
end
