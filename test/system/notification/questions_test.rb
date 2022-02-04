# frozen_string_literal: true

require 'application_system_test_case'

class Notification::QuestionsTest < ApplicationSystemTestCase
  setup do
    @notice_text = 'hatsunoさんから質問がありました。'
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
    first('.select2-selection--single').click
    find('li', text: '[Mac OS X] OS X Mountain Lionをクリーンインストールする').click
    click_button '登録する'
    assert_text '質問を作成しました。'

    visit_with_auth '/notifications', 'mentor'

    within first('.thread-list-item.is-unread') do
      assert_text @notice_text
    end

    assert_equal @notified_count + @mentor_count, Notification.where(kind: @notice_kind).size
  end

  test 'There is no notification to the mentor who posted' do
    visit_with_auth '/questions/new', 'mentor'
    within 'form[name=question]' do
      fill_in('question[title]', with: '皆さんに質問！！')
      fill_in('question[description]', with: '通知行ってますか？')
    end
    first('.select2-selection--single').click
    find('li', text: '[Mac OS X] OS X Mountain Lionをクリーンインストールする').click
    click_button '登録する'
    logout

    login_user users(:mentor).login_name, 'testtest'
    # 通知メッセージが非表示項目でassert_textでは取得できないため、findでvisible指定
    # 存在時、findは複数取得してエラーになるためassert_raisesにて検証
    assert_raises Capybara::ElementNotFound do
      find('mentorさんから質問がありました。', visible: false)
    end
    logout
  end
end
