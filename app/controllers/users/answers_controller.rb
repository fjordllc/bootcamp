# frozen_string_literal: true

class Users::AnswersController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @answers = @user.answers.where(user_id: params[:user_id]).includes(
      {
        question: [
          :correct_answer,
          { user: { avatar_attachment: :blob } },
          :practice,
          :tag_taggings,
          :tags
        ]
      }
    ).order(created_at: :desc).page(params[:page])
  end
end
