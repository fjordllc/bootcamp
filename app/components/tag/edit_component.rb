# frozen_string_literal: true

class Tag::EditComponent < ViewComponent::Base
  attr_reader :tag_id, :tag_name

  def initialize(tag:)
    @tag_id = tag.id
    @tag_name = tag.name
  end
end
