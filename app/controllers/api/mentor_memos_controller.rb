# frozen_string_literal: true

class API::MentorMemosController < API::BaseController
  before_action :require_mentor_login_for_api
  before_action -> { doorkeeper_authorize! :write }, only: %i[create], if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :mentor }, only: %i[create], if: -> { doorkeeper_token.present? }
  before_action :set_user, only: %i[create]

  def create
    mentor_memo = @user.mentor_memos.new(content: user_params[:content], author: current_user)
    if mentor_memo.save
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_user
    @user = User.find(params[:user][:user_id])
  end

  def user_params
    params.require(:user).permit(:content)
  end
end
