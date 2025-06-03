# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  QuestionsProperty = Struct.new(:title, :empty_message)

  def index
    @practice = Practice.find(params[:practice_id])
    @questions = @practice.questions.includes(%i[correct_answer practice answers tag_taggings tags]).order(created_at: :desc).page(params[:page])
    @questions_property = QuestionsProperty.new('全ての質問', '質問はありません。')
  end
end
