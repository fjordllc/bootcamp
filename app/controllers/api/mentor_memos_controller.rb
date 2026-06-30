# frozen_string_literal: true

class API::MentorMemosController < API::BaseController
  before_action :require_mentor_login_for_api
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :mentor }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }
  before_action :set_user, only: %i[create update destroy]
  before_action :set_memo, only: %i[update destroy]
  before_action :authorize_memo, only: %i[update destroy]

  def create
    memo = MentorMemo.new(mentor_memo_params)
    memo.writer = current_user
    memo.recipient = @user

    if memo.save
      render partial: 'users/mentor_memo', locals: { memo: }, status: :created
    else
      head :bad_request
    end
  end

  def update
    if @mentor_memo.update(mentor_memo_params)
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    @mentor_memo.destroy

    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_memo
    @mentor_memo = @user.received_memos.find(params[:id])
  end

  def mentor_memo_params
    params.require(:mentor_memo).permit(:body)
  end

  def authorize_memo
    return if @mentor_memo.writer == current_user || current_user.admin?

    head :forbidden
  end
end
