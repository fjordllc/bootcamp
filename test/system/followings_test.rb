# frozen_string_literal: true

require 'application_system_test_case'

class FollowingsTest < ApplicationSystemTestCase
  test 'follow' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    click_button '日報をフォロー'
    assert_button 'フォローを解除'
  end

  test 'unfollow' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    click_button '日報をフォロー'
    click_button 'フォローを解除'
    assert_button '日報をフォロー'
  end

  test 'show following lists' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    click_button '日報をフォロー'
    assert_text 'フォローを解除'
    visit '/users?target=followings'
    assert_text users(:hatsuno).login_name
  end

  test 'receive a notification when following user create a report' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    click_button '日報をフォロー'

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
  end

  test "receive a notification when following user's report has comment" do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    click_button '日報をフォロー'

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
  end
end
