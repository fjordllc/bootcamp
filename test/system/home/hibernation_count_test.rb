# frozen_string_literal: true

require 'application_system_test_case'

module Home
  class HibernationCountTest < ApplicationSystemTestCase
    test 'show my hibernation count' do
      visit_with_auth '/', 'hukki'
      assert_text 'あなたの休会回数'
    end

    test 'not show hibernation count' do
      # 休会したことが無いユーザー
      visit_with_auth '/', 'kimura'
      assert_no_text 'あなたの休会回数'

      # メンター
      visit_with_auth '/', 'mentormentaro'
      assert_no_text 'あなたの休会回数'

      # 管理者
      visit_with_auth '/', 'komagata'
      assert_no_text 'あなたの休会回数'
    end
  end
end
