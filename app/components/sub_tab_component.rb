# frozen_string_literal: true

class SubTabComponent < ViewComponent::Base
  def initialize(name:, link:, active: false, count: nil, badge: nil)
    @name = name
    @link = link
    @active = active
    @count = count
    @badge = badge
  end

  private

  attr_reader :name, :link, :active, :count, :badge
end
