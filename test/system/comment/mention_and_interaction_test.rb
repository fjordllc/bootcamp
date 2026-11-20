# frozen_string_literal: true

require 'application_system_test_case'

class MentionAndInteractionTest < ApplicationSystemTestCase
  test 'suggest mention to mentor' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment')
    end

    # Type @ to trigger mention suggestion
    find('#js-new-comment[data-tribute]').send_keys('@')

    # Wait for mention suggestion to appear using Capybara's built-in wait
    assert_selector 'span.mention', text: 'mentor', wait: 10
  end

  test 'company logo appear when adviser belongs to the company post comment' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'senpai'
    fill_in('comment[description]', with: 'test')
    click_button 'コメントする'
    assert_text 'test'
    assert_includes ['companies-logos-2.webp', 'default.png'], File.basename(find('img.thread-comment__company-logo')['src'])
  end

  test 'clicking mention menu background does not raise an error or select a candidate' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    find('#js-new-comment[data-tribute]').send_keys('@men')
    assert_selector '.tribute-container li .mention', text: 'mentor'

    execute_script <<~JS
      window.mentionMenuErrors = []
      window.addEventListener('error', (event) => window.mentionMenuErrors.push(event.message))
      const menu = Array.from(document.querySelectorAll('.tribute-container'))
        .find((element) => element.offsetHeight > 0)
      for (const target of [menu, menu.querySelector('ul')]) {
        target.dispatchEvent(new MouseEvent('mousedown', { bubbles: true, cancelable: true }))
      }
    JS

    assert_empty evaluate_script('window.mentionMenuErrors')
    assert_equal '@men', find('#js-new-comment').value
    find('.tribute-container li .mention', text: 'mentor', exact_text: true).click
    assert_equal '@mentor ', find('#js-new-comment').value
    assert_no_selector '.tribute-container'
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'senpai'
    within(:css, '.a-file-insert') do
      assert_selector 'input.new-comment-file-input', visible: false
    end
    assert_equal '.new-comment-file-input', find('textarea.a-text-input')['data-input']
  end
end
