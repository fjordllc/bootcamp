# frozen_string_literal: true

class SubTabsComponent < ViewComponent::Base
  def initialize(tabs:, active_tab:)
    @tabs = tabs
    @active_tab = active_tab
  end

  private

  attr_reader :tabs, :active_tab
end
