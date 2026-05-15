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

  test 'show pagination' do
    user = users(:komagata)
    Announcement.delete_all
    26.times do
      Announcement.create(title: 'test', description: 'test', user:, published_at: DateTime.now)
    end
    visit_with_auth '/announcements', 'kimura'
    assert_selector 'nav.pagination', count: 2
  end

  test 'announcement has a comment form ' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'
    assert_selector '.thread-comment-form'
  end

  test 'show user name_kana next to user name' do
    announcement = announcements(:announcement1)
    user = announcement.user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth "/announcements/#{announcement.id}", 'kimura'
    assert_text decorated_user.long_name
  end

  test 'show comment count' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'

    fill_in 'new_comment[description]', with: 'コメント数表示のテストです。'
    click_button 'コメントする'
    assert_selector 'p', text: 'コメント数表示のテストです。'

    visit current_path
    assert_selector '#comment_count', text: '2'
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_announcement_path, 'komagata'
    wait_for_announcement_form
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'show the latest announcements' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'
    assert_text '最新のお知らせ'
  end
end
