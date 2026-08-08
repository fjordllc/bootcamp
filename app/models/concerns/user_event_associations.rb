# frozen_string_literal: true

module UserEventAssociations
  extend ActiveSupport::Concern

  included do
    has_many :events, dependent: :destroy
    has_many :participations, dependent: :destroy

    has_many :participate_events,
             through: :participations,
             source: :event

    has_many :regular_events, dependent: :destroy
    has_many :regular_event_organizers, dependent: :destroy
    has_many :regular_event_participations, dependent: :destroy

    has_many :organize_regular_events,
             through: :regular_event_organizers,
             source: :regular_event

    has_many :participate_regular_events,
             through: :regular_event_participations,
             source: :regular_event
  end
end
