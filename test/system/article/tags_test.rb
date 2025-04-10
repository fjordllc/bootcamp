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
    page.accept_confirm do
      click_on '公開する'
    end
    assert_text '記事を作成しました'
    created_article = Article.find_by(title: 'タグ追加のテスト記事')
    assert_equal tags, created_article.tag_list.sort
  end

  test 'mentor can view and use tags' do
    article = Article.create!(
      user: users(:mentormentaro),
      title: 'タグ付きテスト記事',
      body: '2つタグが付与された記事です',
      tag_list: %w[FirstTag SecondTag],
      wip: false
    )

    visit_with_auth article_path(article), 'mentormentaro'
    assert_selector 'ul.a-tags__items li.a-tags__item', text: 'FirstTag'
    assert_selector 'ul.a-tags__items li.a-tags__item', text: 'SecondTag'
    click_link 'SecondTag'
    assert_text 'タグ付きテスト記事'

    visit_with_auth article_path(article), 'hatsuno'
    assert_no_selector 'ul.a-tags__items li.a-tags__item'
    visit articles_path(tag: 'SecretTag')
    assert_current_path articles_path
    assert_text '管理者・メンターとしてログインしてください'
  end
end
