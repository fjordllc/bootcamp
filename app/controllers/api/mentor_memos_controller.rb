# frozen_string_literal: true

class API::MentorMemosController < API::BaseController
  before_action :require_mentor_login_for_api
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :mentor }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }
  before_action :set_user, only: %i[create]
  before_action :set_mentor_memo, only: %i[update destroy]
  before_action :authorize_author, only: %i[update destroy]

  def create
    mentor_memo = @user.mentor_memos.new(content: user_params[:content], author: current_user)
    if mentor_memo.save
      head :ok
    else
      head :bad_request
    end
  end

  def update
    if @mentor_memo.update(content: user_params[:content])
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    if @mentor_memo.destroy
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_user
    @user = User.find(params[:user][:user_id])
  end

  def set_mentor_memo
    @mentor_memo = MentorMemo.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:content)
  end

  def authorize_author
    head :forbidden unless @mentor_memo.author == current_user
  end
end
