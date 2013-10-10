class PracticesController < ApplicationController
  before_action :require_login, except: %w(index show)
  before_action :set_practice, only: %w(show edit update destroy sort)
  respond_to :html, :json

  def index
    if current_user.present? and params['target'].blank?
      redirect_to practices_path(target: 'me')
    end
    @categories = Category.all
  end

  def show
  end

  def new
    @practice = Practice.new
  end

  def edit
  end

  def create
    @practice = Practice.new(practice_params)

    if @practice.save
      notify("#{current_user.full_name}(#{current_user.login_name})がプラクティス「#{@practice.title}」を作成しました。 #{url_for(@practice)}")
      redirect_to @practice, notice: t('practice_was_successfully_created')
    else
      render :new
    end
  end

  def update
    if @practice.update(practice_params)
      notify("#{current_user.full_name}(#{current_user.login_name})がプラクティス「#{@practice.title}」を編集しました。 #{url_for(@practice)}")
      flash[:notice] = t('practice_was_successfully_updated')
    end
    respond_with @practice
  end

  def destroy
    @practice.destroy
    notify("#{current_user.full_name}(#{current_user.login_name})がプラクティス「#{@practice.title}」を削除しました。")
    redirect_to practices_url, notice: t('practice_was_successfully_deleted')
  end

  private
    def practice_params
      params.require(:practice).permit(
        :title,
        :description,
        :goal,
        :target,
        :category_id,
        :position
      )
    end

    def set_practice
      @practice = Practice.find(params[:id])
    end
end
