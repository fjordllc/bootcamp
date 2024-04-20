# frozen_string_literal: true

require 'test_helper'

class WorkComponentTest < ViewComponent::TestCase
  setup do
    @user = users(:kimura).extend(UserDecorator)
    @work = works(:work1)
    @work.user = @user
    render_inline(Works::WorkComponent.new(work: @work))
  end

  def test_work_thumbnail
    assert_selector 'img.thumbnail-card__image'
  end

  def test_creator_avatar
    assert_selector 'img.a-user-icons__item-icon.a-user-icon[title="kimura (Kimura Tadasi)"][src="/images/users/avatars/default.png"]'
  end
end
