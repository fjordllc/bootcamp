# frozen_string_literal: true

require 'application_system_test_case'

class Notification::FollowingsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'receive a notification when following user create a report' do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    find('.following').click
    click_button 'コメントあり'

    visit_with_auth user_path(users(:hatsuno)), 'mentormentaro'
    find('.following').click
    click_button 'コメントなし'

    visit_with_auth '/reports/new', 'hatsuno'
    within('form[name=report]') do
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

    visit_with_auth '/notifications', 'mentormentaro'
    assert_text 'hatsunoさんが日報【 test title 】を書きました！'
  end
end
