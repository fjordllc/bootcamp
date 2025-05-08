# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  QuestionsProperty = Struct.new(:title, :empty_message)

  def index
    @practice = Practice.find(params[:practice_id])
    @empty_message = empty_message
    @questions = @practice.questions.includes(%i[correct_answer practice answers tag_taggings tags]).order(created_at: :desc).page(params[:page])
    @questions_property = QuestionsProperty.new('全ての質問', '質問はありません。')
  end

  private

  def empty_message
    case params[:target]
    when 'solved'
      '解決済みのQ&Aはありません。'
    when 'not_solved'
      '未解決のQ&Aはありません。'
    else
      '質問はありません。'
    end
  end
end
