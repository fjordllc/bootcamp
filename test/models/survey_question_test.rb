# frozen_string_literal: true

require 'test_helper'

class SurveyQuestionTest < ActiveSupport::TestCase
  test '#answer_required_choice_exists?' do
    radio_button_survey_question = survey_questions(:survey_question2)
    check_box_survey_question = survey_questions(:survey_question3)

    assert radio_button_survey_question.answer_required_choice_exists?(radio_button_survey_question.id)
    assert check_box_survey_question.answer_required_choice_exists?(check_box_survey_question.id)
  end
end
