# frozen_string_literal: true

require 'browserless_system_test_case'

module Articles
  class PermissionBrowserlessTest < BrowserlessSystemTestCase
    setup do
      @article = articles(:article1)
    end

    test "general user can't see edit and delete buttons" do
      visit_with_auth article_path(@article), 'kimura'
      assert_no_text '内容修正'
      assert_no_text '削除'
    end

    test 'admin can see edit and delete buttons' do
      visit_with_auth article_path(@article), 'komagata'
      assert_text '内容修正'
      assert_text '削除'
    end

    test 'mentor can see edit and delete buttons' do
      visit_with_auth article_path(@article), 'mentormentaro'
      assert_text '内容修正'
      assert_text '削除'
    end
  end
end
