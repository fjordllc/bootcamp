# frozen_string_literal: true

require 'browserless_system_test_case'

module Products
  class TweetBrowserlessTest < BrowserlessSystemTestCase
    test 'can not see tweet button when current_user does not complete a practice' do
      visit_with_auth "/products/#{products(:product1).id}", 'yamada'
      assert_no_text 'Xに修了ポストする'
    end

    test 'not display learning completion message when a user whom the product does not belongs to visits show' do
      visit_with_auth "/products/#{products(:product65).id}", 'yamada'
      assert_no_text '喜びをXにポストする！'
    end
  end
end
