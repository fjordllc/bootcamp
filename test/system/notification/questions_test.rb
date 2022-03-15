# frozen_string_literal: true

require 'application_system_test_case'

class Notification::QuestionsTest < ApplicationSystemTestCase
  setup do
    @notice_kind = Notification.kinds['came_question']
    @notified_count = Notification.where(kind: @notice_kind).size
    @mentor_count = User.mentor.size
  end

  test 'mentor receive notification when question is posted' do
    visit_with_auth '/questions/new', 'hatsuno'
    within 'form[name=question]' do
      fill_in('question[title]', with: 'メンターに質問！！')
      fill_in('question[description]', with: '通知行ってますか？')
    end
    click_button '登録する'
    assert_text '質問を作成しました。'

    visit_with_auth '/notifications', 'mentormentaro'
    within first('.thread-list-item.is-unread') do
      assert_text 'hatsunoさんから質問「メンターに質問！！」が投稿されました。'
    end

    assert_equal @notified_count + @mentor_count, Notification.where(kind: @notice_kind).size
  end

  test 'There is no notification to the mentor who posted' do
    visit_with_auth '/questions/new', 'mentormentaro'
    within 'form[name=question]' do
      fill_in('question[title]', with: '皆さんに質問！！')
      fill_in('question[description]', with: '通知行ってますか？')
    end
    click_button '登録する'
    assert_text '質問を作成しました。'

    visit '/notifications'
    assert_selector '.page-header__title', text: '通知'
    assert_no_text 'mentormentaroさんから質問「皆さんに質問！！」が投稿されました。'
  end
end
