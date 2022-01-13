# frozen_string_literal: true

class Report < ApplicationRecord
  include Commentable
  include Checkable
  include Footprintable
  include Searchable
  include Reactionable
  include Watchable
  include WithAvatar
  include Mentioner
  include Bookmarkable
  include Taskable

  enum emotion: {
    sad: 1,
    soso: 0,
    happy: 2
  }

  attribute :no_learn, :boolean

  has_many :learning_times, -> { order(:started_at) }, dependent: :destroy, inverse_of: :report
  validates_associated :learning_times
  accepts_nested_attributes_for :learning_times, reject_if: :all_blank, allow_destroy: true
  has_and_belongs_to_many :practices # rubocop:disable Rails/HasAndBelongsToMany
  belongs_to :user, touch: true
  alias sender user

  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
  validates :user, presence: true
  validates :reported_on, presence: true, uniqueness: { scope: :user }
  validates :emotion, presence: true
  validate :reported_on_or_before_today

  after_save   ReportCallbacks.new
  after_create ReportCallbacks.new
  after_destroy ReportCallbacks.new
  after_initialize :set_default_emotion, if: :new_record?

  columns_for_keyword_search :title, :description

  mentionable_as :description

  scope :default_order, -> { order(reported_on: :desc, created_at: :desc) }

  scope :unchecked, lambda {
    includes(:checks).where(checks: { id: nil })
  }

  scope :wip, -> { where(wip: true) }

  scope :not_wip, -> { where(wip: false) }

  scope :list, lambda {
    with_avatar
      .preload([:comments, { checks: { user: { avatar_attachment: :blob } } }])
      .default_order
  }

  class << self
    def faces
      @faces ||= emotions.keys
                         .zip(%w[emotion/sad.svg emotion/soso.svg emotion/happy.svg])
                         .to_h
                         .with_indifferent_access
    end

    def save_as_markdown!(reports, folder_path)
      reports.each do |report|
        File.open("#{folder_path}/#{report.reported_on}.md", 'w') do |file|
          file.puts("# #{report.title}")
          file.puts
          file.puts(report.description)
        end
      end
    end
  end

  def previous
    Report.where(user: user)
          .where('reported_on < ?', reported_on)
          .order(reported_on: :desc)
          .first
  end

  def next
    Report.where(user: user)
          .where('reported_on > ?', reported_on)
          .order(:reported_on)
          .first
  end

  def first?
    serial_number == 1
  end

  def serial_number
    Report.select(:id)
          .where(user: user)
          .order(:created_at)
          .index(self) + 1
  end

  def first_public?
    !wip && published_at.nil?
  end

  def set_default_emotion
    self.emotion ||= 2
  end

  def total_learning_time
    (learning_times.sum(&:diff) / 60).to_i
  end

  def reported_on_or_before_today
    errors.add(:reported_on, 'は今日以前の日付にしてください') if reported_on > Date.current
  end
end
