# frozen_string_literal: true

require 'application_system_test_case'

class TalksTest < ApplicationSystemTestCase
  test 'talks action uncompleted page displays when admin logined ' do
    visit_with_auth '/', 'komagata'
    click_link '相談', match: :first
    assert_equal '/talks/action_uncompleted', current_path
  end

  test 'Displays users talks page when user loged in ' do
    visit_with_auth '/', 'kimura'
    click_link '相談'
    assert_text 'kimuraさんの相談部屋'
  end

  test 'push guraduation button in talk room when admin logined' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    accept_confirm do
      click_link '卒業にする'
    end
    assert_text '卒業済'
  end

  test 'admin can see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    assert_selector '.page-tabs'
  end

  test 'non-admin user cannot see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    assert_no_selector '.page-tabs'
  end

  test 'upload PDF to talk comment' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'

    pdf_path = Rails.root.join('test/fixtures/files/users/diplomas/diploma.pdf')
    find('.new-comment-file-input', visible: false).set(pdf_path)

    assert_field 'js-new-comment', with: /\[diploma\.pdf \(.+ KB\)\]\(http.+diploma\.pdf\)/
    assert_no_field 'js-new-comment', with: /undefined/
  end

  test 'loads previous comments eight at a time' do
    user = users(:kimura)
    user.talk.comments.delete_all
    17.times do |index|
      user.talk.comments.create!(user:, description: "相談コメント#{index}", created_at: index.minutes.ago)
    end

    visit_with_auth talk_path(user.talk), 'komagata'

    assert_text '相談コメント0'
    assert_no_text '相談コメント15'
    page.execute_script("document.querySelector('.thread-comments-more button').click()")
    assert_text '相談コメント15'
    assert_button '前のコメント（ 1 ）'
  end

  test 'loads an old comment linked by its anchor' do
    user = users(:kimura)
    user.talk.comments.delete_all
    comments = Array.new(17) do |index|
      user.talk.comments.create!(user:, description: "アンカーコメント#{index}", created_at: index.minutes.ago)
    end

    visit_with_auth "#{talk_path(user.talk)}#comment_#{comments.last.id}", 'komagata'

    assert_text 'アンカーコメント16'
    assert_text 'アンカーコメント0'
    page.execute_script("document.querySelector('.thread-comments-more button').click()")
    assert_text 'アンカーコメント15'
    page.execute_script("document.querySelector('.thread-comments-more button').click()")
    assert_selector '.thread-comments-more.is-hidden', visible: :hidden
    assert_selector "#comment_#{comments.last.id}", count: 1
    rendered_ids = page.all('.thread-comments__items > .thread-comment').map { |comment| comment[:id] }
    assert_equal comments.reverse.pluck(:id).map { |id| "comment_#{id}" }, rendered_ids
  end
end
