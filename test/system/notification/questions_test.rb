# frozen_string_literal: true

require 'application_system_test_case'

class Notification::QuestionsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_kind = Notification.kinds['came_question']
    @notified_count = Notification.where(kind: @notice_kind).size
    @mentor_count = User.mentor.size
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
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
    within first('.card-list-item.is-unread') do
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

  test 'should not notify when an already published question was updated' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth "/questions/#{questions(:question8).id}", 'kimura'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
    end
    click_button '更新する'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問「更新されたタイトル」が投稿されました。'
  end

  test 'should not notify when an already published question was updated as WIP' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth "/questions/#{questions(:question8).id}", 'kimura'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
    end
    click_button 'WIP'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問「更新されたタイトル」が投稿されました。'
  end

  test 'should not notify when a newly question was created as WIP' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問「WIPタイトル」が投稿されました。'
  end

  test 'notify when a newly question was created as published' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '公開タイトル'
      fill_in 'question[description]', with: '公開本文'
    end
    find('input[value="登録する"]').click
    find('.flash__message', text: '質問を作成しました。')
    find('.page-content-header__title', text: '公開タイトル')

    visit_with_auth '/notifications?status=unread', 'komagata'
    find('.card-list-item-title__link-label', text: 'kimuraさんから質問「公開タイトル」が投稿されました。')
  end

  test 'should not notify when a WIP question was updated' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問「更新されたWIPタイトル」が投稿されました。'
  end

  test 'notify when a WIP question with modification was updated as published' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新された公開タイトル'
      fill_in 'question[description]', with: '更新された公開本文'
    end
    click_button '質問を公開'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text 'kimuraさんから質問「更新された公開タイトル」が投稿されました。'
  end

  test 'notify when a WIP question without modification was updated as published' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    click_button '内容修正'
    click_button '質問を公開'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text 'kimuraさんから質問「WIPタイトル」が投稿されました。'
  end

  test 'should not notify when a published question with modification was updated as WIP' do
    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '公開タイトル'
      fill_in 'question[description]', with: '公開本文'
    end
    click_button '登録する'
    assert_text '質問を作成しました。'

    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions', 'kimura'
    click_link '公開タイトル'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問「更新されたWIPタイトル」が投稿されました。'
  end

  test 'should not notify when a published question without modification was updated as WIP' do
    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '公開タイトル'
      fill_in 'question[description]', with: '公開本文'
    end
    click_button '登録する'
    assert_text '質問を作成しました。'

    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions', 'kimura'
    click_link '公開タイトル'
    click_button '内容修正'
    click_button 'WIP'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問「公開タイトル」が投稿されました。'
  end

  test 'should not notify when a published question was updated' do
    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '公開タイトル'
      fill_in 'question[description]', with: '公開本文'
    end
    click_button '登録する'
    assert_text '質問を作成しました。'

    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/questions', 'kimura'
    click_link '公開タイトル'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
    end
    click_button '更新する'
    assert_text '質問を更新しました'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'kimuraさんから質問「更新されたタイトル」が投稿されました。'
  end

  test 'delete question with notification' do
    visit_with_auth '/questions', 'kimura'
    click_link '質問する'
    fill_in 'question[title]', with: 'タイトルtest'
    fill_in 'question[description]', with: '内容test'

    assert_difference -> { Question.count }, 1 do
      click_button '登録する'
      assert_text '質問を作成しました。'
    end

    visit_with_auth '/notifications', 'komagata'
    assert_text 'yameoさんが退会しました。'
    assert_text 'kimuraさんから質問「タイトルtest」が投稿されました。'

    visit_with_auth '/questions', 'kimura'
    click_on 'タイトルtest'
    assert_difference -> { Question.count }, -1 do
      accept_confirm do
        click_link '削除する'
      end
      assert_text '質問を削除しました。'
    end

    visit_with_auth '/notifications', 'komagata'
    assert_text 'yameoさんが退会しました。'
    assert_no_text 'kimuraさんから質問「タイトルtest」が投稿されました。'
  end
end
