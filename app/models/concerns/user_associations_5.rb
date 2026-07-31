# frozen_string_literal: true

module UserAssociations5
  extend ActiveSupport::Concern

  included do
    has_many :passive_relationships,
             class_name: 'Following',
             foreign_key: 'followed_id',
             inverse_of: 'followed',
             dependent: :destroy

    has_many :followers,
             through: :passive_relationships,
             source: :follower

    has_many :organize_regular_events,
             through: :regular_event_organizers,
             source: :regular_event

    has_many :participate_regular_events,
             through: :regular_event_participations,
             source: :regular_event

    has_many :coding_test_submissions, dependent: :destroy

    has_many :learning_time_frames,
             through: :learning_time_frames_users
  end
end
