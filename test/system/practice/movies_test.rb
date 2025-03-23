# frozen_string_literal: true

require 'application_system_test_case'

class Practice::MoviesTest < ApplicationSystemTestCase
  test 'show listing movies' do
    visit_with_auth "/practices/#{practices(:practice1).id}/movies", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関する動画 | FBC', title
    assert_selector 'h2.page-header__title', text: 'OS X Mountain Lionをクリーンインストールする'
    assert_selector '.page-tabs__item-link.is-active', text: '動画 （1）'
  end
end
