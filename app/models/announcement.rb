# frozen_string_literal: true

class Announcement < ApplicationRecord
  include Commentable
  include Footprintable
  include Searchable
  include Reactionable
  include WithAvatar
  include Watchable
  include SearchHelper

  enum target: {
    all: 0,
    students: 1,
    job_seekers: 2
  }, _prefix: true

  has_many :watches, as: :watchable, dependent: :destroy
  has_many :footprints, as: :footprintable, dependent: :destroy
  belongs_to :user
  alias sender user

  validates :title, presence: true
  validates :description, presence: true
  validates :target, presence: true

  columns_for_keyword_search :title, :description

  scope :wip, -> { where(wip: true) }

  def self.copy_announcement(announcement_id)
    original = find(announcement_id)
    new(title: original.title, description: original.description, target: original.target)
  end

  def self.copy_template_by_resource(template_file, params = {})
    template = MessageTemplate.load(template_file, params:)
    new(title: template['title'], description: template['description'])
  end
end
