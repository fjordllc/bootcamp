# frozen_string_literal: true

class Event < ApplicationRecord
  include WithAvatar
  include Commentable
  include Footprintable
  include Reactionable
  include Watchable
  include Searchable
  include Bookmarkable

  delegate :opening?, :before_opening?, :closing?, :ended?, to: :opening_status

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :open_start_at, presence: true
  validates :open_end_at, presence: true

  with_options if: -> { start_at && end_at } do
    validates :end_at, comparison: { greater_than: :start_at, message: ': イベント終了日時はイベント開始日時よりも後の日時にしてください。' }
  end

  with_options if: -> { open_start_at && open_end_at } do
    validates :open_end_at, comparison: { greater_than: :open_start_at, message: ': 募集終了日時は募集開始日時よりも後の日時にしてください。' }
  end

  with_options if: -> { open_start_at && start_at } do
    validates :open_start_at, comparison: { less_than: :start_at, message: ': 募集開始日時はイベント開始日時よりも前の日時にしてください。' }
  end

  with_options if: -> { open_end_at && end_at } do
    validates :open_end_at, comparison: { less_than_or_equal_to: :end_at, message: ': 募集終了日時はイベント終了日時よりも前の日時にしてください。' }
  end

  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :users, through: :participations
  attribute :announcement_of_publication, :boolean

  columns_for_keyword_search :title, :description

  scope :wip, -> { where(wip: true) }
  scope :related_to, ->(user) { user.job_seeker ? all : where.not(job_hunting: true) }
  scope :scheduled_on, ->(date) { where(start_at: date.midnight...(date + 1.day).midnight, wip: false) }
  scope :not_ended, -> { where('end_at > ?', Time.current) }
  scope :scheduled_on_without_ended, ->(date) { scheduled_on(date).not_ended }

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description location capacity start_at end_at open_start_at open_end_at wip created_at updated_at user_id job_hunting]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user participations users comments reactions watches]
  end

  def participants
    users.where('participations.enable = true').order(created_at: :asc)
  end

  def waitlist
    users.where('participations.enable = false').order(created_at: :asc)
  end

  def can_participate?
    participants.count < capacity
  end

  def cancel_participation!(user)
    participation = participations.find_by(user_id: user.id)
    participation.destroy

    return unless participation.enable

    move_up_participation = waiting_particpations.first

    return unless move_up_participation

    move_up_participation.update!(enable: true)
    send_notification(move_up_participation.user)
  end

  def send_notification(receiver)
    ActivityDelivery.with(receiver:, event: self).notify(:moved_up_event_waiting_user)
  end

  def can_move_up_the_waitlist?
    waitlist.count.positive? && can_participate?
  end

  def self.fetch_participated_ids(user)
    user.participations.pluck(:event_id)
  end

  def self.fetch_upcoming_ids
    Event.where('start_at > ?', Date.current).pluck(:id)
  end

  def first_come_participations
    participations.order(created_at: :asc)
  end

  def opening_status
    EventOpeningStatus.new(self)
  end

  private

  def first_come_first_served
    users.order('participations.created_at asc')
  end

  def waiting_particpations
    participations.disabled
                  .order(created_at: :asc)
  end
end
