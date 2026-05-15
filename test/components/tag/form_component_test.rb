# frozen_string_literal: true

require 'test_helper'

class Tag::FormComponentTest < ViewComponent::TestCase
  setup do
    @user = users(:machida)
    @component = Tag::FormComponent.new(
      taggable: @user,
      param_name: 'user[tag_list]',
      input_id: 'user_tag_list',
      editable: true
    )
    render_inline(@component)
  end

  def test_initial_tags
    assert_equal 'デザイナー,ギター', @component.initial_tags
  end

  def test_taggable_type
    assert_equal 'User', @component.taggable_type
  end

  def test_taggable_id
    assert_equal @user.id.to_s, @component.taggable_id
  end

  def test_editable
    assert @component.editable?
  end
end
