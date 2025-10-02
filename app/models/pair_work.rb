# frozen_string_literal: true

class PairWork < ApplicationRecord
  include Searchable
  include Commentable
  include Reactionable
  include Watchable
  include WithAvatar
  include Mentioner

  PairWorksProperty = Struct.new(:title, :empty_message)

  has_many :schedules, dependent: :destroy, inverse_of: :pair_work
  belongs_to :user
  belongs_to :practice, optional: true
  belongs_to :buddy, class_name: 'User', optional: true
  accepts_nested_attributes_for :schedules, allow_destroy: true
  alias sender user

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  validates :schedules, presence: true
  before_validation :set_published_at, if: :will_be_published?
  validate :reserved_at_in_schedules?, on: :update

  scope :solved, -> { where.not(reserved_at: nil) }
  scope :not_solved, -> { where(reserved_at: nil) }
  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
  scope :not_held, -> { not_solved.or(where('reserved_at > ?', Date.current)) }
  scope :by_target, lambda { |target|
    case target
    when 'solved'
      solved
    when 'not_solved'
      not_solved.not_wip
    else
      all
    end
  }
  scope :upcoming_pair_works, lambda { |user|
                                today = Date.current
                                within_day = today.midnight...(today + 3).midnight
                                PairWork.where(user_id: user.id).or(PairWork.where(buddy_id: user.id))
                                        .solved
                                        .where(reserved_at: within_day)
                              }

  columns_for_keyword_search :title, :description

  mentionable_as :description

  def self.generate_pair_works_property(target)
    case target
    when 'solved'
      PairWorksProperty.new('ペア確定済みのペアワーク', 'ペア確定済みのペアワークはありません。')
    when 'not_solved'
      PairWorksProperty.new('募集中のペアワーク', '募集中のペアワークはありません。')
    else
      PairWorksProperty.new('全てのペアワーク', 'ペアワークはありません。')
    end
  end

  def self.unsolved_badge(current_user:)
    return nil if !current_user.admin_or_mentor?

    PairWork.not_solved.not_wip.size
  end

  def self.matching_permission?(user, params)
    matching = params[:buddy_id] && params[:reserved_at] && !params.key?(:title) && !params.key?(:description)
    matching && user.mentor?
  end

  def generate_notice_message(action_name)
    return 'ペアワークをWIPとして保存しました。' if wip?

    {
      create: 'ペアワークを作成しました。',
      update: 'ペアワークを更新しました。',
      destroy: 'ペアワークを削除しました。'
    }[action_name]
  end

  def solved?
    !reserved_at.nil?
  end

  def important?
    comments.blank? && !solved?
  end

  private

  def will_be_published?
    !wip && published_at.nil?
  end

  def set_published_at
    self.published_at = Time.current
  end

  def reserved_at_in_schedules?
    return if reserved_at.nil?

    errors.add(:reserved_at, 'は提案されたスケジュールに含まれていません。') unless schedules.map(&:proposed_at).include?(reserved_at)
  end
end
