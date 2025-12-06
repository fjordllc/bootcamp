# frozen_string_literal: true

require 'application_system_test_case'

module CurrentUser
  class TraineeTest < ApplicationSystemTestCase
    test 'should not show training end date if user is not trainee' do
      visit_with_auth edit_current_user_path, 'kimura'
      assert has_no_field?('user_training_ends_on')
    end

    test 'show training end date if user is trainee' do
      visit_with_auth edit_current_user_path, 'kensyu'
      assert has_field?('user_training_ends_on')
    end

    test 'update value of training end date' do
      training_ends_on = Date.current.next_year
      visit_with_auth edit_current_user_path, 'kensyu'
      fill_in 'user_training_ends_on', with: training_ends_on
      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'
      visit_with_auth edit_current_user_path, 'kensyu'
      assert_field 'user_training_ends_on', with: training_ends_on.to_s
    end
  end
end
