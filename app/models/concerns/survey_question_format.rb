# frozen_string_literal: true

module SurveyQuestionFormat
  extend ActiveSupport::Concern

  def normalize_blank_check_box_and_radio_button!
    columns = %i[title_of_reason description_of_reason]
    columns.each do |column|
      self[column] = nil if self[column].blank?
    end
  end

  def normalize_blank_check_box_choice_and_radio_button_choice!
    columns = %i[choices]
    columns.each do |column|
      self[column] = nil if self[column].blank?
    end
  end

  def normalize_blank_linear_scale!
    columns = %i[first last title_of_reason description_of_reason]
    columns.each do |column|
      self[column] = nil if self[column].blank?
    end
  end
end
