# frozen_string_literal: true

class Movie < ApplicationRecord
  include Searchable
  include WithAvatar
  include Taggable
  include Reactionable
  include Commentable
  include Watchable
  include Bookmarkable

  belongs_to :user
  has_many :practices_movies, dependent: :nullify
  has_many :practices, through: :practices_movies
  belongs_to :last_updated_user, class_name: 'User', optional: true
  has_one_attached :movie_data

  validates :user, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :movie_data, presence: true

  scope :wip, -> { where(wip: true) }
end
