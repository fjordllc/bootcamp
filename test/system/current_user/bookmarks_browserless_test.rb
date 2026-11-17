# frozen_string_literal: true

require 'browserless_system_test_case'

class CurrentUser::BookmarksBrowserlessTest < BrowserlessSystemTestCase
  test 'show edit button and bookmarks when current user has bookmarks' do
    visit_with_auth '/current_user/bookmarks', 'kimura'

    assert_selector 'label', text: '編集'
    assert_selector 'input#bookmark_edit', visible: false

    assert_text '作業週1日目'
    assert_selector '.card-list-item__label', text: '日報'
    assert_text '今日はローカルで怖話を動かしてみました。 rbenv で ruby を動かすのは初めてだったので、色々手間取りました。'
    assert_text 'komagata(コマガタ マサキ)'
    assert_text '2017年01月01日(日) 00:00'
  end
end
