# frozen_string_literal: true

require 'application_system_test_case'

class FollowingsTest < ApplicationSystemTestCase
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

    visit_with_auth user_path(users(:yamada)), 'kimura'
    find('.following').click
    click_button 'コメントなし'
    assert_selector 'summary', text: 'コメントなし'

    visit '/users?target=followings'
    assert_text users(:hatsuno).login_name
    assert_text users(:yamada).login_name
  end

  test 'show followings with comments' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'
    assert_selector 'summary', text: 'コメントあり'

    visit_with_auth user_path(users(:yamada)), 'kimura'
    find('.following').click
    click_button 'コメントなし'
    assert_selector 'summary', text: 'コメントなし'

    visit '/users?target=followings&watch=true'
    assert_text users(:hatsuno).login_name
    assert_no_text users(:yamada).login_name
  end

  test 'show followings with no comments' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'
    assert_selector 'summary', text: 'コメントあり'

    visit_with_auth user_path(users(:yamada)), 'kimura'
    find('.following').click
    click_button 'コメントなし'
    assert_selector 'summary', text: 'コメントなし'

    visit '/users?target=followings&watch=false'
    assert_no_text users(:hatsuno).login_name
    assert_text users(:yamada).login_name
  end

  test 'receive a notification when following user create a report' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'

    visit_with_auth user_path(users(:hatsuno)), 'yamada'
    find('.following').click
    click_button 'コメントなし'

    visit_with_auth '/reports/new', 'hatsuno'
    within('#new_report') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    assert_text '日報を保存しました。'

    visit_with_auth '/notifications', 'kimura'
    assert_text 'hatsunoさんが日報【 test title 】を書きました！'

    visit_with_auth '/notifications', 'yamada'
    assert_text 'hatsunoさんが日報【 test title 】を書きました！'
  end

  test "receive a notification when following user's report has comment" do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'

    visit_with_auth user_path(users(:hatsuno)), 'yamada'
    find('.following').click
    click_button 'コメントなし'

    visit_with_auth '/reports/new', 'hatsuno'
    within('#new_report') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'

    comment = 'テストのコメントです'

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: comment)
    end
    click_button 'コメントする'
    assert_text comment

    visit_with_auth '/notifications', 'kimura'
    assert_text 'hatsunoさんの【 「test title」の日報 】にhatsunoさんがコメントしました。'

    visit_with_auth '/notifications', 'yamada'
    assert_no_text 'hatsunoさんの【 「test title」の日報 】にhatsunoさんがコメントしました。'
  end
end
