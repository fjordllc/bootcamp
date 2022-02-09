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

    visit_with_auth '/notifications', 'yamada'

    within first('.thread-list-item.is-unread') do
      assert_text @notice_text
    end

    assert_equal @notified_count + @mentor_count, Notification.where(kind: @notice_kind).size
  end

  test 'There is no notification to the mentor who posted' do
    visit_with_auth '/questions/new', 'yamada'
    within 'form[name=question]' do
      fill_in('question[title]', with: '皆さんに質問！！')
      fill_in('question[description]', with: '通知行ってますか？')
    end
    first('.select2-selection--single').click
    find('li', text: '[Mac OS X] OS X Mountain Lionをクリーンインストールする').click
    click_button '登録する'
    logout

    login_user users(:yamada).login_name, 'testtest'
    # 通知メッセージが非表示項目でassert_textでは取得できないため、findでvisible指定
    # 存在時、findは複数取得してエラーになるためassert_raisesにて検証
    assert_raises Capybara::ElementNotFound do
      find('yamadaさんから質問がありました。', visible: false)
    end
    logout
  end

  test 'Do not notify if create question as WIP' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth new_question_path, 'kimura'
    within('.form') do
      fill_in('question[title]', with: 'WIPtest')
      fill_in('question[description]', with: 'WIPtest')
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問がありました。'
  end

  test 'Do not notify if update question as WIP' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth new_question_path, 'kimura'
    within('.form') do
      fill_in('question[title]', with: 'WIPtest')
      fill_in('question[description]', with: 'WIPtest')
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    click_button '内容修正'
    fill_in('question[description]', with: 'WIPtest update')
    click_button 'WIP'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問がありました。'
  end

  test 'notify if update question as WIP to published' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth new_question_path, 'kimura'
    within('.form') do
      fill_in('question[title]', with: 'WIPtest')
      fill_in('question[description]', with: 'WIPtest')
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    click_button '内容修正'
    fill_in('question[description]', with: 'WIPtest update')
    click_button '質問を公開'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text 'kimuraさんから質問がありました。'
  end

  test 'notify if update question as WIP to published without modification' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth new_question_path, 'kimura'
    within('.form') do
      fill_in('question[title]', with: 'WIPtest')
      fill_in('question[description]', with: 'WIPtest')
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    click_button '内容修正'
    click_button '質問を公開'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text 'kimuraさんから質問がありました。'
  end
end
