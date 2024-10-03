# frozen_string_literal: true

require 'test_helper'

class PageTabsComponentTest < ViewComponent::TestCase
  setup do
    tabs = [
      { name: 'name1', link: '/foo' },
      { name: 'name2', link: '/bar' }
    ]
    render_inline(PageTabsComponent.new(tabs:, active_tab: 'name1'))
  end
  def test_default
    assert_selector '.page-tabs .container ul.page-tabs__items li.page-tabs__item a', text: 'name1'
  end
end
