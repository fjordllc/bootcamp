# frozen_string_literal: true

module CommentableController
  extend ActiveSupport::Concern

  def commentable
    klass = params[:comment][:commentable_type].constantize
    klass.find(params[:comment][:commentable_id])
  end
end
