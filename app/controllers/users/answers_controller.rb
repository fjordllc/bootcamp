# frozen_string_literal: true

class Users::AnswersController < ApplicationController
  before_action :require_login

  def index
    @user = User.find(params[:user_id])
    @answers = @user.answers.includes(
      {
        question: [
          :correct_answer,
          { user: [:company, { avatar_attachment: :blob }] },
          :practice,
          :tag_taggings,
          :tags
        ]
      }
    ).order(created_at: :desc)
  end
end
