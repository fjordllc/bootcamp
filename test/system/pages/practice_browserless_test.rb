# frozen_string_literal: true

require 'browserless_system_test_case'

module Pages
  class PracticeBrowserlessTest < BrowserlessSystemTestCase
    test 'Check the list of columns on the right of the document' do
      visit_with_auth "/pages/#{pages(:page7).id}", 'kimura'
      assert_link 'OS X Mountain Lionをクリーンインストールする'
      assert_link 'プラクティスに紐付いたDocs'
      assert_link '全て見る'
    end
  end
end
