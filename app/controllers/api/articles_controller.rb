# frozen_string_literal: true

class API::ArticlesController < API::BaseController
  ARTICLE_ATTRIBUTES = %i[
    title body tag_list user_id thumbnail thumbnail_type summary display_thumbnail_in_body target wip
  ].freeze
  UPDATE_ARTICLE_ATTRIBUTES = [*ARTICLE_ATTRIBUTES, :published_at].freeze

  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }
  before_action :require_admin_or_mentor_login_for_api, only: %i[create update destroy]
  before_action :authorize_wip_index, only: %i[index]
  before_action :set_article, only: %i[show update destroy]
  before_action :authorize_wip_preview, only: %i[show]

  def index
    @articles = article_scope.preload(:tags).page(params[:page])
    @articles = @articles.tagged_with(params[:tag]) if params[:tag].present?
  end

  def show; end

  def create
    attributes = create_article_params
    user_id = attributes.delete(:user_id)
    @article = Article.new
    apply_wip_param(@article, attributes)
    @article.assign_attributes(attributes)

    return unless assign_contributor(@article, user_id, fallback: current_user)

    if @article.save
      ActiveSupport::Notifications.instrument('article.create', article: @article)
      render :show, status: :created
    else
      render_validation_errors(@article)
    end
  end

  def update
    attributes = update_article_params

    if attributes.key?(:user_id)
      user_id = attributes.delete(:user_id)
      return unless assign_contributor(@article, user_id)
    end

    apply_wip_param(@article, attributes)
    apply_published_at_param(@article, attributes)
    @article.assign_attributes(attributes)

    if @article.save
      ActiveSupport::Notifications.instrument('article.create', article: @article)
      render :show, status: :ok
    else
      render_validation_errors(@article)
    end
  end

  def destroy
    @article.destroy
    ActiveSupport::Notifications.instrument('article.destroy', article: @article)
    head :no_content
  end

  private

  def article_scope
    scope = Article.with_attached_thumbnail.includes(user: { avatar_attachment: :blob })
    if wip_requested?
      scope.where(wip: true).order(created_at: :desc)
    else
      scope.where(wip: false).order(published_at: :desc, created_at: :desc)
    end
  end

  def set_article
    @article = Article.with_attached_thumbnail.includes(:tags, user: { avatar_attachment: :blob })
                      .find_by(id: params[:id])
    render_not_found('記事が見つかりません。') unless @article
  end

  def authorize_wip_index
    return unless wip_requested?
    return if current_user.admin_or_mentor?

    render json: { error: '権限がありません' }, status: :forbidden
  end

  def authorize_wip_preview
    return if performed? || @article.published? || current_user.admin_or_mentor?
    return if params[:token].present? && @article.token == params[:token]

    render json: { error: '権限がありません' }, status: :forbidden
  end

  def wip_requested?
    ActiveModel::Type::Boolean.new.cast(params[:wip])
  end

  def create_article_params = permitted_article_params(ARTICLE_ATTRIBUTES)

  def update_article_params = permitted_article_params(UPDATE_ARTICLE_ATTRIBUTES)

  def permitted_article_params(attributes)
    params.require(:article).permit(*attributes, tag_list: [])
  end

  def assign_contributor(article, user_id, fallback: nil)
    contributor = user_id.present? ? User.admins_and_mentors.find_by(id: user_id) : fallback
    return article.user = contributor if contributor

    render json: { errors: { user_id: ['に指定できないユーザーです'] } }, status: :unprocessable_entity
    false
  end

  def apply_wip_param(article, attributes)
    return unless attributes.key?(:wip)

    article.wip = ActiveModel::Type::Boolean.new.cast(attributes.delete(:wip))
    article.generate_token! if article.wip?
  end

  def apply_published_at_param(article, attributes)
    return unless attributes.key?(:published_at)

    published_at = attributes.delete(:published_at)
    article.published_at = published_at unless article.wip?
  end
end
