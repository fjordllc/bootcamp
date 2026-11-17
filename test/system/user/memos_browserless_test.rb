# frozen_string_literal: true

require 'browserless_system_test_case'

class User::MemoBrowserlessTest < BrowserlessSystemTestCase
  test 'admin can see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'メンター向けユーザーメモ'
  end

  test 'mentor can see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'mentormentaro'
    assert_text 'メンター向けユーザーメモ'
  end

  test 'adviser can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'advijirou'
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'trainee can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'kensyu'
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'graduate can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'sotugyou'
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'student can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'hatsuno'
    assert_no_text 'メンター向けユーザーメモ'
  end
end
