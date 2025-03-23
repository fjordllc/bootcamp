# frozen_string_literal: true

require 'application_system_test_case'

class Practice::MoviesTest < ApplicationSystemTestCase
  test 'show listing movies' do
    visit_with_auth "/practices/#{practices(:practice1).id}/movies", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関する動画 | FBC', title
    assert_selector 'h2.page-header__title', text: 'OS X Mountain Lionをクリーンインストールする'
    assert_selector '.page-tabs__item-link.is-active', text: '動画 （1）'
  end

  test 'show listing no movies' do
    visit_with_auth "/practices/#{practices(:practice10).id}/movies", 'hatsuno'
    assert_equal 'sshdをインストールするに関する動画 | FBC', title
    assert_selector 'h2.page-header__title', text: 'sshdをインストールする'
    assert_selector '.page-tabs__item-link.is-active', text: '動画 （0）'
    assert_text '動画はまだありません'
  end

  test 'show movie related to practices when click title link' do
    visit_with_auth "/practices/#{practices(:practice1).id}/movies", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関する動画 | FBC', title
    assert_selector '.thumbnail-card__title-link.a-text-link', text: 'OS X Mountain Lionをクリーンインストールするに関連する動画'
    click_link_or_button 'OS X Mountain Lionをクリーンインストールするに関連する動画'

    assert_current_path movie_path(movies(:movie5))
    assert_selector 'h1.page-content-header__title', text: 'OS X Mountain Lionをクリーンインストールするに関連する動画'
  end
end
