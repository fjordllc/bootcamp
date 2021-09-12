# frozen_string_literal: true

require 'application_system_test_case'

class Practice::CompletionTest < ApplicationSystemTestCase
  test 'not logging-in user can access show' do
    visit "/practices/#{practices(:practice1).id}/completion"
    assert_text '「OS X Mountain Lionをクリーンインストールする」を修了しました'
  end

  test 'show page includes tweet button' do
    visit "/practices/#{practices(:practice1).id}/completion"
    assert_text 'Twitterにシェアする'

    click_link 'Twitterにシェアする'
    assert_includes current_url, 'https://twitter.com/intent/tweet'
  end
end
