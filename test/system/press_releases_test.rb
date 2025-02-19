# frozen_string_literal: true

require 'application_system_test_case'

class PressReleasesTest < ApplicationSystemTestCase
  test 'show listing press releases' do
    visit press_releases_path
    assert_text 'プレスリリース'
    assert_selector '.articles'
  end

  test 'show only published press releases' do
    visit press_releases_path
    assert_selector '.thumbnail-card.a-card', count: 24
    visit press_releases_path(page: 2)
    assert_selector '.thumbnail-card.a-card', count: 6
  end
end
