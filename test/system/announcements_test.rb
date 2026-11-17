# frozen_string_literal: true

require 'application_system_test_case'

class AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'show comment count' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'

    fill_in 'comment[description]', with: 'コメント数表示のテストです。'
    click_button 'コメントする'
    assert_selector 'p', text: 'コメント数表示のテストです。'

    visit current_path
    assert_selector 'a.a-meta[href="#comments"] span.is-emphasized', text: '2'
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_announcement_path, 'komagata'
    wait_for_announcement_form
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end
end
