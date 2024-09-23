# frozen_string_literal: true

class PageTabComponent < ViewComponent::Base
  def initialize(name:, link:, active: true, enable: true, count: nil, badge: nil)
    @name = name
    @link = link
    @active = active
    @enable = enable
    @count = count
    @badge = badge
  end

  private

  attr_reader :name, :link, :active, :enable, :count, :badge
end
