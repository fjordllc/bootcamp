# frozen_string_literal: true

require 'application_system_test_case'

module CurrentUser
  class CompanyTest < ApplicationSystemTestCase
    test 'nonadmins cannot select their companies' do
      %w[kimura mentormentaro advijirou sotugyou kensyu].each do |login_name|
        visit_with_auth edit_current_user_path, login_name
        assert_no_selector 'select[name="user[company_id]"]', visible: :all
      end
    end

    test 'admin can select their company' do
      visit_with_auth edit_current_user_path, 'komagata'
      assert_selector 'select[name="user[company_id]"]', visible: :all
      assert_text '企業'
      within '.choices__inner' do
        assert_text 'Lokka Inc.'
      end
    end

    test 'trainee can see their existing company without changing it' do
      visit_with_auth edit_current_user_path, 'kensyu'
      within '.js-training-info-block' do
        assert_text companies(:company2).name
        assert_field 'user_training_ends_on'
        assert_no_selector 'select[name="user[company_id]"]', visible: :all
      end
    end
  end
end
