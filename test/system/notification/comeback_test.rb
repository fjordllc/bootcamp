# frozen_string_literal: true

require 'application_system_test_case'

class Notification::ComebackTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify mentor when student comeback' do
    visit new_comeback_path
    within('form[name=comeback]') do
      fill_in 'user[email]', with: 'kyuukai@fjord.jp'
      fill_in 'user[password]', with: 'testtest'
    end

    VCR.use_cassette 'subscription/create', vcr_options do
      click_on '休会から復帰する'
    end
    logout

    notifications = Notification.where(user: users(:mentormentaro), kind: Notification.kinds[:comebacked])
    assert(notifications.any? { |n| n.message.include?('kyuukaiさんが休会から復帰しました！') })
  end
end
