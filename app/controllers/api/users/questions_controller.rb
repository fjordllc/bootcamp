# frozen_string_literal: true

class API::Users::QuestionsController < API::BaseController
  before_action :require_login_for_api

  def index
    @user = User.find(params[:user_id])
    @questions = @user.questions
                      .includes(%i[correct_answer practice answers tag_taggings tags])
                      .order(created_at: :desc)
                      .page(params[:page])
  end
end
