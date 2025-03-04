# frozen_string_literal: true

require 'test_helper'

class SubTabsComponentTest < ViewComponent::TestCase
  def test_default
    tabs = [
      { name: 'タブ1', link: '/path/to/tab1' },
      { name: 'タブ2', link: '/path/to/tab2' }
    ]
    render_inline(SubTabsComponent.new(tabs:, active_tab: 'タブ1'))

    assert_selector 'nav.tab-nav .container ul.tab-nav__items li.tab-nav__item', count: 2
    assert_selector 'li.tab-nav__item a.tab-nav__item-link', text: 'タブ1'
    assert_selector 'li.tab-nav__item a.tab-nav__item-link', text: 'タブ2'
  end

  def test_active_tab
    tabs = [
      { name: 'タブ1', link: '/path/to/tab1' },
      { name: 'タブ2', link: '/path/to/tab2' }
    ]
    render_inline(SubTabsComponent.new(tabs:, active_tab: 'タブ1'))

    assert_selector 'li.tab-nav__item a.tab-nav__item-link.is-active', text: 'タブ1'
    assert_no_selector 'li.tab-nav__item a.tab-nav__item-link.is-active', text: 'タブ2'
  end

  def test_different_active_tab
    tabs = [
      { name: 'タブ1', link: '/path/to/tab1' },
      { name: 'タブ2', link: '/path/to/tab2' }
    ]
    render_inline(SubTabsComponent.new(tabs:, active_tab: 'タブ2'))

    assert_no_selector 'li.tab-nav__item a.tab-nav__item-link.is-active', text: 'タブ1'
    assert_selector 'li.tab-nav__item a.tab-nav__item-link.is-active', text: 'タブ2'
  end

  def test_no_active_tab
    tabs = [
      { name: 'タブ1', link: '/path/to/tab1' },
      { name: 'タブ2', link: '/path/to/tab2' }
    ]
    render_inline(SubTabsComponent.new(tabs:, active_tab: 'タブ3'))

    assert_no_selector 'li.tab-nav__item a.tab-nav__item-link.is-active'
  end
end
