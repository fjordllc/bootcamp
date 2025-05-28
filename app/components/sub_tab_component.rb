# frozen_string_literal: true

class SubTabComponent < ViewComponent::Base
  def initialize(name:, link:, active: false)
    @name = name
    @link = link
    @active = active
  end

  private

  attr_reader :name, :link, :active
end
