# frozen_string_literal: true

module UserAccountAssociations
  extend ActiveSupport::Concern

  included do
    belongs_to :company, optional: true
    belongs_to :course

    has_one :discord_profile, dependent: :destroy
    accepts_nested_attributes_for :discord_profile, allow_destroy: true

    has_many :oauth_access_grants,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'

    has_many :oauth_access_tokens,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'

    has_one_attached :avatar
    has_one_attached :profile_image
    has_one_attached :diploma_file

    scope :by_course, ->(target) { joins(:course).where(courses: { title: target }) }
  end
end
