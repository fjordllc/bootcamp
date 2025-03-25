# frozen_string_literal: true

require 'application_system_test_case'

class Article::SponsorshipsTest < ApplicationSystemTestCase
  test 'show listing only sponsorship articles' do
    visit_with_auth new_article_url, 'komagata'
    fill_in 'タイトル', with: 'sponsorshipページに表示される記事のタイトルです。'
    fill_in '本文', with: 'sponsorshipページに表示される記事の本文です。'
    fill_in_tag 'スポンサーシップ'
    click_on '公開する'
    visit sponsorships_path
    assert_selector '.thumbnail-card__inner', count: 1
    assert_text 'sponsorshipページに表示される記事のタイトルです。'
  end
end
