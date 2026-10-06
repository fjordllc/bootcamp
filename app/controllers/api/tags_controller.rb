# frozen_string_literal: true

class API::TagsController < API::BaseController
  TAGGABLE_CLASSES = {
    'User' => User,
    'Page' => Page,
    'Movie' => Movie,
    'Question' => Question,
    'Article' => Article
  }.freeze

  skip_before_action :require_login_for_api
  before_action :validate_taggable_type, only: :index

  def index
    @tags = taggable_type.all_tags
  end

  def update
    tag = ActsAsTaggableOn::Tag.find(params[:id])
    same_name_tag = ActsAsTaggableOn::Tag.find_by(name: tag_params[:name])

    if same_name_tag && replace_tagging_tags_with(same_name_tag)
      head :ok
    elsif tag.update(tag_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def validate_taggable_type
    type = params[:taggable_type]
    head :bad_request unless type.is_a?(String) && TAGGABLE_CLASSES.key?(type)
  end

  def replace_tagging_tags_with(same_name_tag)
    taggings = ActsAsTaggableOn::Tagging.where(tag_id: params[:id])
    taggable_ids = ActsAsTaggableOn::Tagging.where(tag_id: same_name_tag.id).select(:taggable_id)
    taggings.where.not(taggable_id: taggable_ids).update(tag_id: same_name_tag.id)
    taggings.where(taggable_id: taggable_ids).destroy_all
  end

  def tag_params
    params.require(:tag).permit(:name)
  end

  def taggable_type
    TAGGABLE_CLASSES.fetch(params[:taggable_type])
  end
end
