# frozen_string_literal: true

# 外部サービスが、利用者がいまもBootcampにログインできる状態かを確かめるためのAPI。
# 他人の在籍状態を返すため、退会者・休会者の一覧を見られるメンターと管理者だけが呼び出せる。
class API::Users::MembershipsController < API::BaseController
  before_action :require_admin_or_mentor
  before_action :set_user

  def show
    render json: {
      id: @user.id,
      login_name: @user.login_name,
      active: !@user.inactive?
    }
  end

  private

  def require_admin_or_mentor
    render json: { message: '権限がありません。' }, status: :forbidden unless current_user.admin_or_mentor?
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
    render json: { message: 'ユーザーが見つかりません。' }, status: :not_found unless @user
  end
end
