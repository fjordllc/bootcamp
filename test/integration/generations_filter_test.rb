# frozen_string_literal: true

require 'test_helper'

class GenerationsFilterTest < ActionDispatch::IntegrationTest
  test 'filter generations by target' do
    post user_sessions_path, params: { user: { login: 'adminonly', password: 'testtest' } }

    travel_to Time.zone.local(2014, 4, 1, 0, 0, 0) do
      {
        'trainee' => ['研修生', '.a-user-role.is-trainee'],
        'adviser' => ['アドバイザー', '.a-user-role.is-adviser'],
        'graduate' => ['卒業生', '.a-user-role.is-graduate'],
        'mentor' => ['メンター', '.a-user-role.is-mentor'],
        'retired' => ['退会', '.a-user-role.is-retired']
      }.each do |target, (label, role_selector)|
        get generations_path(target:)

        assert_response :success
        assert_select 'a.tab-nav__item-link.is-active', text: label
        assert_includes response.body, "期生別（#{label}）"
        assert_select 'a', text: /5期生/
        assert_select ".a-user-icons__items #{role_selector}"
        assert_select '.a-user-icons__items .a-user-role.is-retired', target == 'retired'
      end
    end
  end

  test 'retired users are shown only to admins' do
    post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }

    get generations_path(target: 'retired')

    assert_redirected_to root_path
    assert_equal '管理者としてログインしてください', flash[:alert]
  end
end
