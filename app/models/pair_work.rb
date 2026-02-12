# frozen_string_literal: true

class PairWork < ApplicationRecord
  include Searchable
  include Commentable
  include Reactionable
  include Watchable
  include WithAvatar
  include Mentioner

  PairWorksProperty = Struct.new(:title, :empty_message)

  has_many :schedules, class_name: 'PairWorkSchedule', dependent: :destroy, inverse_of: :pair_work
  belongs_to :user
  belongs_to :practice, optional: true
  belongs_to :buddy, class_name: 'User', optional: true
  accepts_nested_attributes_for :schedules, allow_destroy: true
  alias sender user

  after_save PairWorkCallbacks.new
  before_destroy PairWorkCallbacks.new, prepend: true
  after_destroy PairWorkCallbacks.new

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  validates :schedules, presence: true
  before_validation :set_published_at, if: :will_be_published?
  validates :reserved_at, presence: { message: 'が選択されていません' }, on: :reserve
  validates :buddy, presence: { message: 'が選択されていません' }, on: :reserve
  validate :reserved_at_in_schedules, on: :reserve
  validate :buddy_is_not_self, on: :reserve

  scope :solved, -> { where.not(reserved_at: nil) }
  scope :not_solved, -> { where(reserved_at: nil) }
  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
  scope :not_held, -> { not_solved.or(where('reserved_at > ?', Time.current)) }
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
                                now = Time.current
                                within_day = now...(now + 3.days)
                                PairWork.where(user_id: user.id).or(PairWork.where(buddy_id: user.id))
                                        .solved
                                        .where(reserved_at: within_day)
                              }

  mentionable_as :description

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description wip reserved_at published_at created_at updated_at buddy_id user_id practice_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user buddy practice schedules comments reactions watches bookmarks]
  end

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

    ::Cache.not_solved_pair_work_count
  end

  def generate_notice_message(action_name)
    return 'ペアワークをWIPとして保存しました。' if wip?

    {
      create: 'ペアワークを作成しました。',
      update: 'ペアワークを更新しました。',
      destroy: 'ペアワークを削除しました。',
      reserve: 'ペアが確定しました。'
    }[action_name]
  end

  def solved?
    !reserved_at.nil?
  end

  def reserve(params)
    assign_attributes(params)
    save(context: :reserve)
  end

  private

  def will_be_published?
    !wip && published_at.nil?
  end

  def set_published_at
    self.published_at = Time.current
  end

  def reserved_at_in_schedules
    errors.add(:reserved_at, 'は提案されたスケジュールに含まれていません。') unless schedules.map(&:proposed_at).include?(reserved_at)
  end

  def buddy_is_not_self
    errors.add(:buddy, 'に自分を指定することはできません。') if user_id == buddy_id
  end
end
