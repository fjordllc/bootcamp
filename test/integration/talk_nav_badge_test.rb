# frozen_string_literal: true

require 'test_helper'

class TalkNavBadgeTest < ActionDispatch::IntegrationTest
  BADGE = '.global-nav a[href^="/talks/"] .global-nav__item-count'

  test 'admin sees the number of action uncompleted talks in the global navigation' do
    login 'komagata'
    get root_path
    assert_select BADGE, text: Talk.action_uncompleted.count.to_s
  end

  test 'mentor, adviser and student do not see the number of action uncompleted talks' do
    %w[mentormentaro advijirou kimura].each do |login_name|
      login login_name
      get root_path
      assert_select '.global-nav'
      assert_select BADGE, false, "#{login_name} should not see the badge"
    end
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end
end
