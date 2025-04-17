# frozen_string_literal: true

require 'application_system_test_case'

class Page::NotLoggedInTest < ApplicationSystemTestCase
  test 'when not logged in user access docs, meta description is displayed' do
    logout
    target_page = pages(:page1)
    visit page_path(target_page)
    meta = page.find("meta[name='description']", visible: false, match: :first)
    expected_content = "オンラインプログラミングスクール「フィヨルドブートキャンプ」のドキュメント「#{target_page.title}」のページです。"
    assert_equal expected_content, meta[:content]
  end
end
