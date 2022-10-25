# frozen_string_literal: true

module SurveyQuestionFormat
  extend ActiveSupport::Concern

  def normalize_blank!(columns)
    columns.each do |column|
      self[column] = nil if self[column].blank?
    end
  end
end
