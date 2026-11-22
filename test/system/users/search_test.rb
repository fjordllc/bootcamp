# frozen_string_literal: true

require 'application_system_test_case'

# 検索する列、対象ごとの絞り込み、検索フォームを出す画面は
# test/integration/users/search_test.rb で確かめる。
class Users::SearchTest < ApplicationSystemTestCase
  test 'search users from the form' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura Tadasi', count: 1

    fill_in 'js-user-search-input', with: 'nobody-matches-this'
    find('#js-user-search-input').send_keys :return
    assert_text '一致するユーザーはいません'
  end
end
