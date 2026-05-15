# frozen_string_literal: true

class SubTabComponentPreview < ViewComponent::Preview
  def default
    render(SubTabComponent.new(name: '全て', link: '/products'))
  end

  def active
    render(SubTabComponent.new(name: '全て', link: '/products', active: true))
  end

  def with_count
    render(SubTabComponent.new(name: '未返信', link: '/products?status=unreplied', active: true, count: 12))
  end

  def with_badge
    render(SubTabComponent.new(name: '自分の担当', link: '/products?status=assigned', badge: 3))
  end
end
