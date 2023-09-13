# frozen_string_literal: true

require 'application_system_test_case'

class Article::TagsTest < ApplicationSystemTestCase
  test 'cat add tag to article' do
    visit_with_auth new_article_url, 'komagata'
    fill_in 'タイトル', with: 'タグ追加のテスト記事'
    fill_in '本文', with: '2つタグが付与された記事です'
    tags = %w[FirstTag SecondTag]
    tags.each do |tag|
      fill_in_tag tag
    end
    assert page.has_text?(tags.first)
    assert page.has_text?(tags.second)
    click_on '公開する'

    created_article = Article.find_by(title: 'タグ追加のテスト記事')
    assert_equal tags, created_article.tag_list.sort
  end
end
