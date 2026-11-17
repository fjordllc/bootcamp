# frozen_string_literal: true

require 'browserless_system_test_case'

class TrainingCompletionBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @user = users(:kensyu)
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    travel_to Time.current
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
    travel_back
  end

  test 'non-trainee user cannot access training completion page' do
    visit_with_auth new_training_completion_path, 'hajime'
    assert_text '研修生としてログインしてください'
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

  test 'shows 未入力 when satisfaction is nil' do
    user = users(:kensyuowata)
    user.update!(satisfaction: nil)

    visit_with_auth "/users/#{user.id}", 'komagata'

    within('.user-metas.is-only-mentor', text: '研修終了情報（非公開）') do
      within('.user-metas__item', text: '選択入力の研修感想') do
        assert_selector '.user-metas__item-value', text: '未入力'
      end
    end
  end
end
