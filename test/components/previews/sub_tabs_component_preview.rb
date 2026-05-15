# frozen_string_literal: true

class SubTabsComponentPreview < ViewComponent::Preview
  def default
    tabs = [
      { name: '全て', link: '/all' },
      { name: '未完了', link: '/incomplete', count: 3 },
      { name: '完了', link: '/complete', count: 12, badge: 2 }
    ]

    render(SubTabsComponent.new(tabs: tabs, active_tab: '全て'))
  end
end
