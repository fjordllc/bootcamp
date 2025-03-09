# frozen_string_literal: true

require 'application_system_test_case'

class Article::SponsorshipsTest < ApplicationSystemTestCase
  test 'show listing only sponsorship articles' do
    visit_with_auth sponsorships_path, 'komagata'
    assert_selector '.thumbnail-card__inner', count: 1
    assert_no_text 'タイトル１'
    assert_no_text 'タイトル２'
    assert_text 'sponsorshipページに表示される記事のタイトルです。'
    click_link_or_button 'ブログ記事のブランクアイキャッチ画像'
    assert_text 'sponsorshipページに表示される記事の本文です。'
  end
end
