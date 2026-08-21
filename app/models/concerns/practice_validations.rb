# frozen_string_literal: true

module PracticeValidations
  extend ActiveSupport::Concern

  included do
    validates :title, presence: true
    validates :description, presence: true
    validates :goal, presence: true
    validates :categories, presence: true
    validate :source_id_cannot_be_self
  end

  private

  def source_id_cannot_be_self
    return unless source_id && id

    errors.add(:source_id, 'cannot reference itself') if source_id == id
  end
end
