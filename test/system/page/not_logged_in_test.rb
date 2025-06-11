# frozen_string_literal: true

require 'application_system_test_case'

class Page::NotLoggedInTest < ApplicationSystemTestCase
  test 'when not logged in user access docs, meta description is displayed' do
    logout
    target_page = pages(:page1)
    visit page_path(target_page)
    assert_selector 'head', visible: false do
      assert_selector "meta[name='description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」のドキュメント「#{target_page.title}」のページです。']", visible: false
    end
  end
end
