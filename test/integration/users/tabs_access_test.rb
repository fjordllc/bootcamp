# frozen_string_literal: true

require 'test_helper'

class Users::TabsAccessTest < ActionDispatch::IntegrationTest
  # 役割 => [全員, 就職活動中, 退会] のリンクが見えるか
  {
    'kimura' => [false, false, false],
    'advijirou' => [false, true, false],
    'mentormentaro' => [true, true, true],
    'komagata' => [true, true, true]
  }.each do |login_name, (all, job_seeking, retired)|
    test "links to user lists shown to #{login_name}" do
      post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }

      get '/users'
      assert_response :success
      assert_select '.page-header__title', text: 'ユーザー'
      assert_equal all, link?('全員'), '全員'
      assert_equal job_seeking, link?('就職活動中'), '就職活動中'
      assert_equal retired, link?('退会'), '退会'

      get '/users?target=retired'
      assert_response :success
      assert_equal retired, link?('退会'), '退会の一覧を直接開いたとき'
    end
  end

  private

  def link?(label)
    css_select('a').any? { |a| a.text.strip.match?(/\A#{label}(\s|（|\z)/) }
  end
end
