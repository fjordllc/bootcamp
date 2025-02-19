# frozen_string_literal: true

require 'application_system_test_case'

class PressKitTest < ApplicationSystemTestCase
  test 'show press releases' do
    visit press_kit_path
    assert_selector '.thumbnail-card.a-card', count: 6
  end
end
