# frozen_string_literal: true

module UserAssociations1
  extend ActiveSupport::Concern

  included do
    belongs_to :company, optional: true
    belongs_to :course
    has_many :learnings, dependent: :destroy
    has_many :pages, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :reports, dependent: :destroy
    has_many :checks, dependent: :destroy
    has_many :footprints, dependent: :destroy
    has_many :images, dependent: :destroy
    has_many :products, dependent: :destroy
    has_many :questions, dependent: :destroy
    has_many :announcements, dependent: :destroy
    has_many :reactions, dependent: :destroy
    has_many :works, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :events, dependent: :destroy
    has_many :participations, dependent: :destroy
    has_many :regular_event_participations, dependent: :destroy
    has_many :answers, dependent: :destroy
    has_many :watches, dependent: :destroy
  end
end
