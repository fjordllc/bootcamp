# frozen_string_literal: true

require 'test_helper'

class Tag::EditComponentTest < ViewComponent::TestCase
  setup do
    @tag = acts_as_taggable_on_tags('cat')
    @component = Tag::EditComponent.new(
      tag: @tag
    )
    render_inline(@component)
  end

  def test_tag_id
    assert_equal @tag.id, @component.tag_id
  end

  def test_tag_name
    assert_equal @tag.name, @component.tag_name
  end
end
