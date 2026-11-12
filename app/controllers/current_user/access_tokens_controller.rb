# frozen_string_literal: true

class CurrentUser::AccessTokensController < ApplicationController
  before_action :require_admin_or_mentor_login

  def index
    @access_tokens = PersonalAccessToken.for_user(current_user)
  end

  def new
    @personal_access_token = PersonalAccessToken.new(user: current_user)
  end

  def create
    @personal_access_token = PersonalAccessToken.new(personal_access_token_params.merge(user: current_user))

    if @personal_access_token.save
      # トークンは発行直後のこの画面でだけ表示する。flashやセッションには載せない。
      response.headers['Cache-Control'] = 'no-store'
      render :create, status: :created
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    PersonalAccessToken.for_user(current_user).find(params[:id]).revoke
    redirect_to current_user_access_tokens_path, notice: 'アクセストークンを失効させました。'
  end

  private

  def personal_access_token_params
    params.fetch(:personal_access_token, {}).permit(:expires_in_days, scopes: [])
  end
end
