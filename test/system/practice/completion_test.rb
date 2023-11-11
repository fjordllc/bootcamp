# frozen_string_literal: true

require 'application_system_test_case'

class Practice::CompletionTest < ApplicationSystemTestCase
  test 'not logging-in user can access show' do
    visit "/practices/#{practices(:practice1).id}/completion"
    assert_text '「OS X Mountain Lionをクリーンインストールする」'
  end

  test 'appropriate meta description is displayed when accessed by non-logged-in user' do
    visit "/practices/#{practices(:practice1).id}"

    assert_selector 'head', visible: false do
      assert_selector "meta[name='description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」のプラクティス「#{practices(:practice1).title}」のページです。']", visible: false
    end
  end

  test 'completion ogp image is displayed' do
    practice = practices(:practice1)
    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
    attach_file 'practice[completion_image]', 'test/fixtures/files/practices/ogp_images/1.jpg', make_visible: true
    click_button '更新する'

    visit "/practices/#{practice.id}/completion"
    assert_selector 'img'
  end
end
