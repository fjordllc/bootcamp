# frozen_string_literal: true

require 'application_system_test_case'

module Markdown
  class SpeakBlockTest < ApplicationSystemTestCase
    test 'speak block test' do
      reset_avatar(users(:mentormentaro))
      visit_with_auth new_page_path, 'komagata'
      fill_in 'page[title]', with: 'インタビュー'
      fill_in 'page[body]', with: ":::speak @mentormentaro\n## 質問\nあああ\nいいい\n:::"

      click_button 'Docを公開'

      assert_css '.a-long-text.is-md.js-markdown-view'
      assert_css '.speak'
      assert_css "a[href='/users/mentormentaro']"
      emoji = find('.js-user-icon.a-user-emoji')
      assert_includes emoji['title'], '@mentormentaro'
      assert_includes emoji['data-user'], 'mentormentaro'
    end

    test 'user profile image markdown test' do
      reset_avatar(users(:mentormentaro))
      visit_with_auth new_page_path, 'komagata'
      fill_in 'page[title]', with: 'レポート'
      fill_in 'page[body]', with: ":@mentormentaro: \n すみません、これも確認していただけませんか？"

      click_button 'Docを公開'

      assert_css '.a-long-text.is-md.js-markdown-view'
      assert_css "a[href='/users/mentormentaro']"
      emoji = find('.js-user-icon.a-user-emoji')
      assert_includes emoji['title'], '@mentormentaro'
      assert_includes emoji['data-user'], 'mentormentaro'
    end

    test 'speak block with arguments test' do
      visit_with_auth new_page_path, 'machida'
      fill_in 'page[title]', with: 'インタビュー'
      fill_in 'page[body]', with: ":::speak(machida, https://avatars.githubusercontent.com/u/168265?v=4)\n## (名前, 画像URL)ver\n:::"

      click_button 'Docを公開'

      assert_css '.a-long-text.is-md.js-markdown-view'
      assert_css '.speak'
      assert_no_css "a[href='/users/machida']"

      img = find('.speak__speaker img')
      assert_includes img['src'], 'https://avatars.githubusercontent.com/u/168265?v=4'
      assert_includes img['title'], 'machida'

      name_span = find('.speak__speaker-name')
      assert_includes name_span.text, 'machida'
    end

    test 'speak block without @ test' do
      visit_with_auth new_page_path, 'machida'
      fill_in 'page[title]', with: 'インタビュー'
      fill_in 'page[body]', with: ":::speak username\n## 名前のみver\n:::"

      click_button 'Docを公開'

      assert_css '.a-long-text.is-md.js-markdown-view'
      assert_css '.speak'
      assert_no_css "a[href='/users/username']"

      img = find('.speak__speaker img')
      assert_includes img['src'], '/images/users/avatars/default.png'
      assert_includes img['title'], 'username'
    end
  end
end
