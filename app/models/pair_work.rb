# frozen_string_literal: true

class PairWork < ApplicationRecord
  include Searchable
  include Commentable
  include Reactionable
  include Watchable
  include WithAvatar
  include Mentioner

  PairWorksProperty = Struct.new(:title, :empty_message)

  has_many :schedules, dependent: :destroy
  belongs_to :user
  belongs_to :practice, optional: true
  belongs_to :buddy, optional: true
  alias sender user

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  before_validation :set_published_at, if: :will_be_published?

  scope :solved, -> { where.not(reserved_at: nil) }
  scope :not_solved, -> { where(reserved_at: nil) }
  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
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

  columns_for_keyword_search :title, :description

  mentionable_as :description

  def self.generate_pair_works_property(target)
    case target
    when 'solved'
      PairWorksProperty.new('相手確定済みのペアワーク', '相手確定済みのペアワークはありません。')
    when 'not_solved'
      PairWorksProperty.new('募集中のペアワーク', '募集中のペアワークはありません。')
    else
      PairWorksProperty.new('全てのペアワーク', 'ペアワークはありません。')
    end
  end

  def generate_notice_message(action_name)
    return 'ペアワークをWIPとして保存しました。' if wip?

    case action_name
    when :create
      'ペアワークを作成しました。'
    when :update
      'ペアワークを更新しました。'
    end
  end

  def solved?
    !!reserved_at
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
end
