# frozen_string_literal: true

require 'test_helper'

class PageTabComponentTest < ViewComponent::TestCase
  setup do
    args = { name: 'name', link: '/foo' }
    render_inline(PageTabComponent.new(**args))
  end
  def test_default
    assert_selector 'li.page-tabs__item a', text: 'name'
  end
end
