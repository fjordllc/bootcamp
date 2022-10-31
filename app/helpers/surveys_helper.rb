# frozen_string_literal: true

module SurveysHelper
  def question_options_within_survey_question
    survey_questions = SurveyQuestion.all
      survey_questions.map do |survey_question|
        ["#{survey_question.title}", survey_question.id]
      end
  end
end
