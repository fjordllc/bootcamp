# frozen_string_literal: true

require 'browserless_system_test_case'

module Bookmarks
  class QuestionBrowserlessTest < BrowserlessSystemTestCase
    setup do
      @question = questions(:question1)
    end

    test 'show question bookmark on lists' do
      visit_with_auth '/current_user/bookmarks', 'kimura'
      assert_text @question.title
    end
  end
end
