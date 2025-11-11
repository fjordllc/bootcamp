# frozen_string_literal: true

require 'application_system_test_case'

class TrainingCompletionTest < ApplicationSystemTestCase
  setup do
    @user = users(:kensyu)
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    travel_to Time.current
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
    travel_back
  end

  test 'user can training complete' do
    @user.discord_profile.times_id = '123456789000000011'
    @user.save!(validate: false)

    Discord::Server.stub(:delete_text_channel, true) do
      visit_with_auth new_training_completion_path, 'kensyu'
      find('label', text: 'とても良い').click
      fill_in 'user[opinion]', with: '研修終了の自由感想'
      perform_enqueued_jobs do
        page.accept_confirm '本当によろしいですか？' do
          click_on '研修を終了する'
        end
        assert_text '研修終了手続きが完了しました。'
      end
    end
    @user.reload
    assert_equal Time.current, @user.training_completed_at
    assert_nil @user.discord_profile.times_id
    assert_nil @user.discord_profile.times_url
    assert_equal 'kensyuさんの研修が終了しました。', users(:komagata).notifications.where(kind: :training_completed).last.message
    assert_equal 'kensyuさんの研修が終了しました。', users(:mentormentaro).notifications.where(kind: :training_completed).last.message

    login_user 'kensyu', 'testtest'
    assert_text '研修終了したユーザーです'
  end

  test 'non-trainee user cannot access training completion page' do
    visit_with_auth new_training_completion_path, 'hajime'
    assert_text '研修生としてログインしてください'
  end

  test 'fails to send email when user completes training due to postmark error' do
    logs = []
    stub_warn_logger = ->(message) { logs << message }
    Rails.logger.stub(:warn, stub_warn_logger) do
      stub_postmark_error = ->(_user) { raise Postmark::InactiveRecipientError }
      UserMailer.stub(:training_complete, stub_postmark_error) do
        visit_with_auth new_training_completion_path, 'kensyu'
        find('label', text: 'とても良い').click
        page.accept_confirm '本当によろしいですか？' do
          click_on '研修を終了する'
        end
        assert_text '研修終了手続きが完了しました'
        assert_equal Time.current, @user.reload.training_completed_at
      end
    end

    assert_match '[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：', logs.to_s
  end

  test 'deletes unchecked products when user completes training' do
    visit_with_auth new_training_completion_path, 'kensyu'
    find('label', text: 'とても良い').click
    assert_difference '@user.products.unchecked.count', -2 do
      page.accept_confirm '本当によろしいですか？' do
        click_on '研修を終了する'
      end
      assert_text '研修終了手続きが完了しました'
    end
    assert_equal Time.current, @user.reload.training_completed_at
  end

  test 'delete WIP reports when user completes training' do
    visit_with_auth '/reports/new', 'kensyu'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end
    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'

    visit new_training_completion_path
    find('label', text: 'とても良い').click

    page.accept_confirm '本当によろしいですか？' do
      click_on '研修を終了する'
    end

    assert_text '研修終了手続きが完了しました'
    assert_not @user.reports.wip.exists?
    assert_equal Time.current, @user.reload.training_completed_at
  end

  test 'does not show training completion to non mentors and non admins' do
    visit_with_auth "/users/#{users(:kensyuowata).id}", 'hatsuno'
    assert_no_text '研修終了情報（非公開）'
  end

  test 'mentors can see training completion info' do
    visit_with_auth "/users/#{users(:kensyuowata).id}", 'mentormentaro'
    assert_text '研修終了情報（非公開）'
  end

  test 'admins can see training completion info' do
    visit_with_auth "/users/#{users(:kensyuowata).id}", 'komagata'
    assert_text '研修終了情報（非公開）'
  end

  test 'removes user from regular event upon training completion' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'kensyu'
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました。'

    visit new_training_completion_path
    find('label', text: 'とても良い').click
    page.accept_confirm '本当によろしいですか？' do
      click_on '研修を終了する'
    end
    assert_text '研修終了手続きが完了しました'
    assert_equal Time.current, @user.reload.training_completed_at

    visit_with_auth "regular_events/#{regular_event.id}", 'komagata'
    within('.card-body') do
      assert_no_selector '.is-kensyu'
    end
  end

  test 'clears github data when user completes training' do
    @user.github_id = '12345'
    @user.github_account = 'github_kensyu'
    @user.github_collaborator = true
    @user.save!(validate: false)

    visit_with_auth new_training_completion_path, 'kensyu'
    find('label', text: 'とても良い').click
    page.accept_confirm '本当によろしいですか？' do
      click_on '研修を終了する'
    end
    assert_text '研修終了手続きが完了しました'

    @user.reload
    assert_equal Time.current, @user.training_completed_at

    assert_nil @user.github_id
    assert_nil @user.github_account
    assert_not @user.github_collaborator
  end
end
