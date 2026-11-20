# frozen_string_literal: true

require 'browserless_system_test_case'

class User::TagsBrowserlessTest < BrowserlessSystemTestCase
  test 'admin can edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth users_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text('タグ名変更')
  end

  test 'users except admin cannot edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth users_tag_path(tag.name, all: 'true'), 'kimura'
    assert_no_text('タグ名変更')
  end
end
