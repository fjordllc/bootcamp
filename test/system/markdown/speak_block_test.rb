# frozen_string_literal: true

require 'application_system_test_case'

module Markdown
  class SpeakBlockTest < ApplicationSystemTestCase
    # 書き方ごとの変換結果は test/javascript/markdown_plugins_test.mjs で確かめる。
    test 'speak block test' do
      reset_avatar(users(:mentormentaro))
      visit_with_auth new_page_path, 'komagata'
      fill_in 'page[title]', with: 'インタビュー'
      fill_in 'page[body]', with: ":::speak @mentormentaro\n## 質問\nあああ\nいいい\n:::"

      click_button 'Docを公開'

      assert_css '.a-long-text.is-md.js-markdown-view'
      assert_css '.speak'
      assert_css "a[href='/users/mentormentaro']"
      emoji = find('.a-user-emoji')
      assert_includes emoji['title'], '@mentormentaro'
      assert_includes emoji['src'], '/@mentormentaro.webp'
    end

    test 'user profile image markdown test' do
      reset_avatar(users(:mentormentaro))
      visit_with_auth new_page_path, 'komagata'
      fill_in 'page[title]', with: 'レポート'
      fill_in 'page[body]', with: ":@mentormentaro: \n すみません、これも確認していただけませんか？"

      click_button 'Docを公開'

      assert_css '.a-long-text.is-md.js-markdown-view'
      assert_css "a[href='/users/mentormentaro']"
      emoji = find('.a-user-emoji')
      assert_includes emoji['title'], '@mentormentaro'
      assert_includes emoji['src'], '/@mentormentaro.webp'
    end
  end
end
