# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i(edit update)
  VALID_SORT_COLUMNS = %w(login_name company_id updated_at report comment asc desc)

  def index
    # return unless VALID_SORT_COLUMNS.include?(params[:sort])
    @order_by = params[:order_by] || "id"
    @order_by = validate_order_by(@order_by)

    @direction = params[:direction] || "desc"
    @direction = validate_order_by(@direction)

    if @order_by == "report"
      @users = User.order_by_reports_count(@direction)
    elsif @order_by == "comment"
      @users = User.order_by_comments_count(@direction)
    else
      @users = User.order(@order_by + " " + @direction)
    end

    @target = params[:target] || "student"
    @users = @users.users_role(@target)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: "ユーザー情報を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    # 今後本人退会時に処理が増えることを想定し、自分自身は削除できないよう
    # 制限をかけておく
    redirect_to admin_users_url, alert: "自分自身を削除する場合、退会から処理を行ってください。" if current_user.id == params[:id]
    user = User.find(params[:id])
    user.destroy
    redirect_to admin_users_url, notice: "#{user.full_name} さんを削除しました。"
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :adviser,
        :login_name,
        :first_name,
        :last_name,
        :email,
        :course_id,
        :description,
        :slack_account,
        :github_account,
        :twitter_account,
        :facebook_url,
        :blog_url,
        :feed_url,
        :password,
        :password_confirmation,
        :job,
        :organization,
        :os,
        :study_place,
        :experience,
        :how_did_you_know,
        :company_id,
        :trainee,
        :nda,
        :graduated_on,
        :retired_on
      )
    end

    def validate_order_by(order_by)
      unless order_by.in?(VALID_SORT_COLUMNS)
        # 事前に定めた属性名以外はエラーとする（ SQLインジェクション対策 ）
        raise ArgumentError, "Attribute not allowed: #{order_by}"
      end
      order_by
    end
end
