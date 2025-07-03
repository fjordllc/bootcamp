# frozen_string_literal: true

class Tag::TagComponent < ViewComponent::Base
  def initialize(initial_tags:, param_name:, input_id:, taggable_type:, taggable_id:, editable: true)
    @initial_tags = initial_tags
    @param_name = param_name
    @input_id = input_id
    @taggable_type = taggable_type
    @taggable_id = taggable_id
    @editable = editable
  end

  def editable?
    @editable
  end
end
