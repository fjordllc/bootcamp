# frozen_string_literal: true

class API::TagsController < API::BaseController
  skip_before_action :require_login_for_api

  def index
    @tags = taggable_type.all_tags
  end

  def update
    tag = ActsAsTaggableOn::Tag.find(params[:id])
    same_name_tag = ActsAsTaggableOn::Tag.find_by(name: tag_params[:name])

    if same_name_tag
      taggings = ActsAsTaggableOn::Tagging.where(tag_id: params[:id])
      taggable_ids = ActsAsTaggableOn::Tagging.where(tag_id: same_name_tag.id).select(:taggable_id)
      update_target = taggings.where.not(taggable_id: taggable_ids)
      destroy_target = taggings.where(taggable_id: taggable_ids)

      head :ok if update_target.update(tag_id: same_name_tag.id) && destroy_target.destroy_all
    elsif tag.update(tag_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end

  def taggable_type
    params[:taggable_type].constantize
  end
end
