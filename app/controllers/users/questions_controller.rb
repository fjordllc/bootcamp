# frozen_string_literal: true

class Users::QuestionsController < ApplicationController
  QuestionsProperty = Struct.new(:title, :empty_message)

  def index
    @user = User.find(params[:user_id])
    @questions = @user.questions.includes(%i[correct_answer practice answers tag_taggings tags]).order(created_at: :desc).page(params[:page])
    @questions_property = QuestionsProperty.new('全ての質問', '質問はありません。')
  end
end
