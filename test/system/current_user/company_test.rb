# frozen_string_literal: true

require 'application_system_test_case'

module CurrentUser
  class CompanyTest < ApplicationSystemTestCase
    test 'mentors advisors graduates admin can register their companies' do
      visit_with_auth '/current_user/edit', 'mentormentaro'
      assert_text '企業'
      within '.choices__inner' do
        assert_text '所属なし'
      end

      visit_with_auth '/current_user/edit', 'advijirou'
      assert_text '企業'
      within '.choices__inner' do
        assert_text '所属なし'
      end

      visit_with_auth '/current_user/edit', 'sotugyou'
      assert_text '企業'
      within '.choices__inner' do
        assert_text '所属なし'
      end

      visit_with_auth '/current_user/edit', 'komagata'
      assert_text '企業'
      within '.choices__inner' do
        assert_text 'Lokka Inc.'
      end
    end

    test 'not mentors advisors graduates admin can not register their companies' do
      visit_with_auth '/current_user/edit', 'kimura'
      assert_no_text '所属なし'
    end
  end
end
