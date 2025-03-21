# frozen_string_literal: true

require 'test_helper'

class SurveyQuestionTest < ActiveSupport::TestCase
  test '#answer_required_choice_exists? returns true when radio button has choice with required reason' do
    radio_button_survey_question = survey_questions(:survey_question2)
    assert radio_button_survey_question.answer_required_choice_exists?(radio_button_survey_question.id)
  end

  test '#answer_required_choice_exists? returns true when check box has choice with required reason' do
    check_box_survey_question = survey_questions(:survey_question3)
    assert check_box_survey_question.answer_required_choice_exists?(check_box_survey_question.id)
  end

  test '#answer_required_choice_exists? returns false when radio button has no choice with required reason' do
    radio_button_survey_question = survey_questions(:survey_question2)

    # RadioButtonChoiceのreason_for_choice_requiredをすべてfalseに設定
    radio_button_survey_question.radio_button.radio_button_choices.each do |choice|
      choice.update(reason_for_choice_required: false)
    end

    assert_not radio_button_survey_question.answer_required_choice_exists?(radio_button_survey_question.id)
  end

  test '#answer_required_choice_exists? returns false when check box has no choice with required reason' do
    check_box_survey_question = survey_questions(:survey_question3)

    # CheckBoxChoiceのreason_for_choice_requiredをすべてfalseに設定
    check_box_survey_question.check_box.check_box_choices.each do |choice|
      choice.update(reason_for_choice_required: false)
    end

    assert_not check_box_survey_question.answer_required_choice_exists?(check_box_survey_question.id)
  end
end
