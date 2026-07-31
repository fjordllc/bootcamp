# frozen_string_literal: true

module UserAssociations4
  extend ActiveSupport::Concern

  included do
    has_many :active_practices,
             through: :active_learnings,
             source: :practice,
             dependent: :destroy

    has_many :active_relationships,
             class_name: 'Following',
             foreign_key: 'follower_id',
             inverse_of: 'follower',
             dependent: :destroy

    has_many :skipped_practices,
             dependent: :destroy

    has_many :practices,
             through: :skipped_practices

    has_many :followees,
             through: :active_relationships,
             source: :followed
  end
end
