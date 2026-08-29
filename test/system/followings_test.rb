# frozen_string_literal: true

require 'application_system_test_case'

class FollowingsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  setup do
    @hatsuno = users(:hatsuno)
    @kimura = users(:kimura)
  end

  test 'follow with comments' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'
    assert_selector 'summary', text: 'コメントあり'
  end

  test 'follow with no comments' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントなし'
    assert_selector 'summary', text: 'コメントなし'
  end

  test 'unfollow' do
    @kimura.follow(@hatsuno, watch: false)

    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'フォローしない'
    assert_selector 'summary', text: 'フォローする'
  end

  test 'show all following lists' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'
    assert_selector 'summary', text: 'コメントあり'

    visit_with_auth user_path(users(:mentormentaro)), 'kimura'
    find('.following').click
    click_button 'コメントなし'
    assert_selector 'summary', text: 'コメントなし'

    visit '/users?target=followings'
    assert_text users(:hatsuno).login_name
    assert_text users(:mentormentaro).login_name
  end

  test 'show followings with comments' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'
    assert_selector 'summary', text: 'コメントあり'

    visit_with_auth user_path(users(:mentormentaro)), 'kimura'
    find('.following').click
    click_button 'コメントなし'
    assert_selector 'summary', text: 'コメントなし'

    visit '/users?target=followings&watch=true'
    assert_text users(:hatsuno).login_name
    assert_no_text users(:mentormentaro).login_name
  end

  test 'show followings with no comments' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'
    assert_selector 'summary', text: 'コメントあり'

    visit_with_auth user_path(users(:mentormentaro)), 'kimura'
    find('.following').click
    click_button 'コメントなし'
    assert_selector 'summary', text: 'コメントなし'

    visit '/users?target=followings&watch=false'
    assert_no_text users(:hatsuno).login_name
    assert_text users(:mentormentaro).login_name
  end
end
