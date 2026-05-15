# frozen_string_literal: true

class PageTabsComponentPreview < ViewComponent::Preview
  def default
    tabs = [
      { name: 'ダッシュボード', link: '/dashboard' },
      { name: '日報', link: '/reports', count: 12 },
      { name: '提出物', link: '/products', count: 5, badge: 3 },
      { name: 'Q&A', link: '/questions' }
    ]

    render(PageTabsComponent.new(tabs: tabs, active_tab: 'ダッシュボード'))
  end

  def with_disabled_tab
    tabs = [
      { name: '概要', link: '/overview' },
      { name: '設定', link: '/settings', enable: false },
      { name: 'メンバー', link: '/members', count: 8 }
    ]

    render(PageTabsComponent.new(tabs: tabs, active_tab: '概要'))
  end
end
