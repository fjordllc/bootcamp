# frozen_string_literal: true

require 'application_system_test_case'

# 検索する列、対象ごとの絞り込み、一覧の切り替えは
# test/integration/talks_search_test.rb で確かめる。
class Talks::SearchTest < ApplicationSystemTestCase
  test 'search talks from the form' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2

    fill_in 'js-talk-search-input', with: 'hoge'
    find('#js-talk-search-input').send_keys :return
    assert_text '一致する相談部屋はありません'
  end
end
