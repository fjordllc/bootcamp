# frozen_string_literal: true

require 'browserless_system_test_case'

module CurrentUser
  class TraineeBrowserlessTest < BrowserlessSystemTestCase
    test 'show training end date if user is trainee' do
      visit_with_auth edit_current_user_path, 'kensyu'
      assert has_field?('user_training_ends_on')
    end
  end
end
