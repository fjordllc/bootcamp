# frozen_string_literal: true

require 'application_system_test_case'

class Article::SponsorshipsTest < ApplicationSystemTestCase
  test 'show listing sponsorship articles' do
    visit_with_auth sponsorships_path, 'komagata'
    assert_selector '.thumbnail-card__inner', count: 1
    click_link_or_button 'ブログ記事のブランクアイキャッチ画像'
    assert_text 'sponsorshipページに表示される記事です。'
  end
end
