# frozen_string_literal: true

class PageTabComponentPreview < ViewComponent::Preview
  def default
    render(PageTabComponent.new(name: 'name', link: '/foo'))
  end
end
