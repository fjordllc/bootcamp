# frozen_string_literal: true

class API::TagsController < API::BaseController
  def index
    @tags = taggable_type.all_tags
  end

  private
    def taggable_type
      params[:taggable_type].constantize
    end
end
