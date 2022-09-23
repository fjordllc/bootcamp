# frozen_string_literal: true

require 'application_system_test_case'

class HibernationTest < ApplicationSystemTestCase
  test 'can not access hibernation without login' do
    visit '/hibernation'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'hibernate' do
    visit_with_auth new_hibernation_path, 'hatsuno'
    within('form[name=hibernation]') do
      fill_in(
        'hibernation[scheduled_return_on]',
        with: (Date.current + 30)
      )
      fill_in('hibernation[reason]', with: 'test')
    end

    VCR.use_cassette 'subscription/update', vcr_options do
      find('.is-checkbox').click
      click_on '休会する'
      page.driver.browser.switch_to.alert.accept
      assert_text '休会処理が完了しました'
    end
  end

  test 'hibernate without scheduled_return_on' do
    visit_with_auth new_hibernation_path, 'hatsuno'
    within('form[name=hibernation]') do
      fill_in('hibernation[reason]', with: 'test')
    end

    find('.is-checkbox').click
    click_on '休会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '復帰予定日を入力してください'
  end
end
