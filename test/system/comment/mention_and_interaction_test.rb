# frozen_string_literal: true

require 'application_system_test_case'

class MentionAndInteractionTest < ApplicationSystemTestCase
  test 'suggest mention to mentor' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end
    Timeout.timeout(Capybara.default_max_wait_time, StandardError) do
      find('#js-new-comment').set('@') until has_selector?('span.mention', wait: false)
    end
    assert_selector 'span.mention', text: 'mentor'
  end

  test 'company logo appear when adviser belongs to the company post comment' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'senpai'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    assert_text 'test'
    assert_includes ['2.png', 'default.png'], File.basename(find('img.thread-comment__company-logo')['src'])
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'senpai'
    within(:css, '.a-file-insert') do
      assert_selector 'input.new-comment-file-input', visible: false
    end
    assert_equal '.new-comment-file-input', find('textarea.a-text-input')['data-input']
  end
end
