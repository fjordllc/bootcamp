# frozen_string_literal: true

require 'browserless_system_test_case'

module Products
  class MentorBrowserlessTest < BrowserlessSystemTestCase
    test 'mentors can see block for mentors' do
      visit_with_auth "/products/#{products(:product2).id}", 'mentormentaro'
      assert_text '直近の日報'
      assert_text 'ユーザー情報'
      assert_text 'ユーザーメモ'
      assert_selector '#side-tabs-nav-4', text: '提出物'
    end

    test 'display recently reports' do
      visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
      within first('.side-tabs .card-list-item') do
        assert_selector 'img[alt="positive"]'
        assert_text '1時間だけ学習'
      end
    end

    test 'product show without recent reports' do
      visit_with_auth "/products/#{products(:product69).id}", 'komagata'
      assert_text '日報はまだありません。'
    end
  end
end
