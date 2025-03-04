# frozen_string_literal: true

require 'test_helper'

class SubTabComponentTest < ViewComponent::TestCase
  def test_default
    render_inline(SubTabComponent.new(name: 'タブ名', link: '/path/to/page'))

    assert_selector 'li.tab-nav__item a.tab-nav__item-link', text: 'タブ名'
    assert_selector 'li.tab-nav__item a[href="/path/to/page"]'
    assert_no_selector 'li.tab-nav__item a.is-active'
  end

  def test_active
    render_inline(SubTabComponent.new(name: 'タブ名', link: '/path/to/page', active: true))

    assert_selector 'li.tab-nav__item a.tab-nav__item-link.is-active', text: 'タブ名'
  end

  def test_inactive
    render_inline(SubTabComponent.new(name: 'タブ名', link: '/path/to/page', active: false))

    assert_selector 'li.tab-nav__item a.tab-nav__item-link', text: 'タブ名'
    assert_no_selector 'li.tab-nav__item a.is-active'
  end
end
