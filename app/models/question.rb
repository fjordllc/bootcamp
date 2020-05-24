# frozen_string_literal: true

class Question < ActiveRecord::Base
  include Searchable
  include Reactionable
  include Watchable
  include WithAvatar

  belongs_to :practice, optional: true
  belongs_to :user, touch: true
  # has_one :correct_answer

  # has_one :best_answer
  # has_one :best_answer, className: "Answer"
  # has_one :best_answer, :class_name "Answer"
  has_many :answers, dependent: :destroy
  has_many :watches, as: :watchable, dependent: :destroy
  alias_method :sender, :user

  after_create QuestionCallbacks.new
  after_destroy QuestionCallbacks.new

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  validates :user, presence: true

  scope :solved, -> { joins(:correct_answer) }
  scope :not_solved, -> { where.not(id: CorrectAnswer.pluck(:question_id)) }

  columns_for_keyword_search :title, :description
end
