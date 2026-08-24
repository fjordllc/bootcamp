# frozen_string_literal: true

class Practice < ApplicationRecord
  include Watchable
  include Searchable
  include PracticeCollaborators
  include PracticeValidations

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
  has_one :practice_quiz, dependent: :destroy

  has_many :coding_test_submissions,
           through: :coding_tests,
           source: :coding_test_submissions

  # Practice copy relationships
  has_many :copied_practices, class_name: 'Practice', foreign_key: 'source_id', dependent: :nullify, inverse_of: :source_practice
  belongs_to :source_practice, class_name: 'Practice', foreign_key: 'source_id', optional: true, inverse_of: :copied_practices

  columns_for_keyword_search :title, :description, :goal

  scope :with_counts, lambda {
    select('practices.*,
           (SELECT COUNT(*) FROM products WHERE products.practice_id = practices.id) as products_count,
           (SELECT COUNT(*) FROM practices_reports WHERE practices_reports.practice_id = practices.id) as reports_count,
           (SELECT COUNT(*) FROM questions WHERE questions.practice_id = practices.id) as questions_count')
  }

  scope :for_mentor_index, lambda {
    with_counts
      .preload(:categories, :submission_answer, :practice_quiz)
      .order(:id)
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description goal created_at updated_at last_updated_user_id submission]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[learnings categories products questions pages movies books last_updated_user]
  end

  def tweet_url(practice_completion_url)
    completion_text = "プラクティス「#{title}」を修了しました🎉"
    # ref: https://developer.twitter.com/en/docs/twitter-for-websites/tweet-button/guides/web-intent
    tweet_param = URI.encode_www_form(text: completion_text, url: practice_completion_url, hashtags: 'fjordbootcamp')
    "https://twitter.com/intent/tweet?#{tweet_param}"
  end

  def grant_course?
    source_id.present?
  end

  def guide_to_grant_course?(user)
    user.grant_course? && source_id.blank?
  end

  def reports_count(include_source: false)
    return reports.count unless include_source

    Report.for_practice_including_source(self).count
  end

  def pages_count(include_source: false)
    return pages.count unless include_source

    Page.for_practice_including_source(self).count
  end

  def text_for_embedding
    text = [title, description, goal].compact.join("\n\n")
    truncate_for_embedding(text)
  end

  def body
    [description, goal].join("\n")
  end
end
