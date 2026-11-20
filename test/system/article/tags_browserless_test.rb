# frozen_string_literal: true

require 'browserless_system_test_case'

class Article::TagsBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @article = Article.create!(
      user: users(:mentormentaro),
      title: 'タグ付きテスト記事',
      body: '2つタグが付与された記事です',
      tag_list: %w[FirstTag SecondTag],
      wip: false
    )
  end

  test 'can view tags' do
    visit article_path(@article)
    assert_selector 'ul.a-tags__items li.a-tags__item', text: 'FirstTag'
    assert_selector 'ul.a-tags__items li.a-tags__item', text: 'SecondTag'
  end
end
