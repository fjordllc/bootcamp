# frozen_string_literal: true

class Tag::TagComponent < ViewComponent::Base
  def initialize(taggable:, param_name:, input_id:, editable: true)
    @taggable = taggable
    @param_name = param_name
    @input_id = input_id
    @editable = editable
  end

  def initial_tags
    @taggable.tag_list.join(',')
  end

  def taggable_type
    @taggable.class.to_s
  end

  def taggable_id
    @taggable.id.to_s
  end

  def editable?
    @editable
  end

  private

  attr_reader :taggable, :param_name, :input_id, :editable
end
