# frozen_string_literal: true

class PageTabsComponent < ViewComponent::Base
  def initialize(tabs:, active_tab:)
    @tabs = tabs
    @active_tab = active_tab
  end

  private

  attr_reader :tabs, :active_tab
end
