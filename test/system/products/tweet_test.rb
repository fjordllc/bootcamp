# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class TweetTest < ApplicationSystemTestCase
    test 'can not see tweet button when current_user does not complete a practice' do
      visit_with_auth "/products/#{products(:product1).id}", 'yamada'
      assert_no_text 'Xに修了ポストする'
    end

    test 'display learning completion message when a user of the completed product visits show first time' do
      visit_with_auth "/products/#{products(:product65).id}", 'kimura'
      assert_text '喜びをXにポストする！'
    end

    test 'not display learning completion message when a user of the completed product visits after the second time' do
      visit_with_auth "/products/#{products(:product65).id}", 'komagata'
      click_button '提出物を合格にする'
      assert_button '提出物の合格を取り消す'
      visit_with_auth "/products/#{products(:product65).id}", 'kimura'
      first('label.card-main-actions__muted-action.is-closer').click
      assert_no_text '喜びをXにポストする！'
      visit current_path
      assert_text 'Xに修了ポストする'
      assert_no_text '喜びをXにポストする！'
    end

    test 'not display learning completion message when a user whom the product does not belongs to visits show' do
      visit_with_auth "/products/#{products(:product65).id}", 'yamada'
      assert_no_text '喜びをXにポストする！'
    end

    test 'not display learning completion message when a user of the non-completed product visits show' do
      visit_with_auth "/products/#{products(:product6).id}", 'sotugyou'
      assert_no_text '喜びをXにポストする！'
    end

    test 'can see tweet button when current_user has completed a practice' do
      visit_with_auth "/products/#{products(:product2).id}", 'kimura'
      assert_text 'Xに修了ポストする'

      find('.a-button.is-tweet').click
      assert_text '喜びをXにポストする！'
    end
  end
end
