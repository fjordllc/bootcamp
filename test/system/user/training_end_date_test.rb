# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'show training end date if user is a trainee and has a training end date' do
    user = users(:kensyu)
    visit_with_auth user_path(user.id), 'kensyu'
    assert has_text?('研修終了日')
    assert has_text?('2022年04月01日')
  end

  test 'does not display training end date if user is a trainee and not has a training end date' do
    user = users(:kensyu)
    training_ends_on = nil
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    fill_in 'user_training_ends_on', with: training_ends_on
    click_on '更新する'
    visit_with_auth user_path(user.id), 'kensyu'
    assert has_no_field?('user_training_ends_on')
  end
end
