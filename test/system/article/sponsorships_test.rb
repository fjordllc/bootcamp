# frozen_string_literal: true

require 'application_system_test_case'

class Article::SponsorshipsTest < ApplicationSystemTestCase
  test 'show listing only sponsorship articles' do
    sponsorship_article = Article.create!(
      title: 'sponsorshipページに表示される記事のタイトルです。',
      body: 'sponsorshipページに表示される記事の本文です。',
      user: users(:komagata),
      wip: false,
      published_at: '2022-01-01 00:00:00',
      thumbnail_type: :prepared_thumbnail
    )
    sponsorship_article.tag_list.add('スポンサーシップ')
    sponsorship_article.save

    visit_with_auth sponsorships_path, 'komagata'
    assert_selector '.thumbnail-card__inner', count: 1
    assert_text 'sponsorshipページに表示される記事のタイトルです。'
  end
end
