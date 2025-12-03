# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::QuestionsTest < NotificationSystemTestCase
  include ActiveJob::TestHelper
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_kind = Notification.kinds['came_question']
    @notified_count = Notification.where(kind: @notice_kind).size
    @mentor_count = User.mentor.size

    mock_openai_chat_completion
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

    perform_enqueued_jobs do
      click_button '登録する'
      assert_text '質問を作成しました。'
    end

    assert_user_has_notification(user: users(:mentormentaro), kind: Notification.kinds[:came_question], text: 'hatsunoさんから質問「メンターに質問！！」が投稿されました。')

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

    assert_user_has_no_notification(user: users(:mentormentaro), kind: Notification.kinds[:came_question], text: 'mentormentaroさんから質問「皆さんに質問！！」が投稿されました。')
  end

  test 'should not notify when an already published question was updated' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    visit_with_auth "/questions/#{questions(:question8).id}", 'kimura'
    click_link '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
    end
    click_button '更新する'
    assert_text '質問を更新しました'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「更新されたタイトル」が投稿されました。', unread: true)
  end

  test 'should not notify when an already published question was updated as WIP' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    visit_with_auth "/questions/#{questions(:question8).id}", 'kimura'
    click_link '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「更新されたタイトル」が投稿されました。', unread: true)
  end

  test 'should not notify when a newly question was created as WIP' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「WIPタイトル」が投稿されました。', unread: true)
  end

  test 'notify when a newly question was created as published' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '公開タイトル'
      fill_in 'question[description]', with: '公開本文'
    end
    click_button '登録する'
    assert_text '質問を作成しました。'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「公開タイトル」が投稿されました。', unread: true)
  end

  test 'should not notify when a WIP question was updated' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「更新されたWIPタイトル」が投稿されました。', unread: true)
  end

  test 'notify when a WIP question with modification was updated as published' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新された公開タイトル'
      fill_in 'question[description]', with: '更新された公開本文'
    end
    perform_enqueued_jobs do
      click_button '質問を公開'
      assert_text '質問を更新しました'
    end

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「更新された公開タイトル」が投稿されました。', unread: true)
  end

  test 'notify when a WIP question without modification was updated as published' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    visit_with_auth '/questions/new', 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    click_button '質問を公開'
    assert_text '質問を更新しました'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「WIPタイトル」が投稿されました。', unread: true)
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
    click_link '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「更新されたWIPタイトル」が投稿されました。', unread: true)
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
    click_link '内容修正'
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「公開タイトル」が投稿されました。', unread: true)
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
    click_link '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
    end
    click_button '更新する'
    assert_text '質問を更新しました'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「更新されたタイトル」が投稿されました。', unread: true)
  end

  test 'delete question by mentor with notification' do
    visit_with_auth '/questions', 'kimura'
    click_link '質問する'
    fill_in 'question[title]', with: 'タイトルtest'
    fill_in 'question[description]', with: '内容test'

    assert_difference -> { Question.count }, 1 do
      click_button '登録する'
      assert_text '質問を作成しました。'
    end

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「タイトルtest」が投稿されました。')

    visit_with_auth '/questions', 'komagata'
    click_on 'タイトルtest'
    assert_text 'コメントする'
    assert_difference -> { Question.count }, -1 do
      accept_confirm do
        click_link '削除する'
      end
      assert_text '質問を削除しました。'
    end

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_question], text: 'kimuraさんから質問「タイトルtest」が投稿されました。')
  end

  test 'notify to questioner when a week has passed since last answer' do
    questioner = users(:kimura)
    answerer = users(:komagata)
    question = Question.create!(
      title: 'テストの質問',
      description: 'テスト',
      user: questioner,
      created_at: '2022-10-31',
      updated_at: '2022-10-31',
      published_at: '2022-10-31'
    )
    Answer.create!(
      description: '最後の回答',
      user: answerer,
      question:,
      created_at: '2022-10-31',
      updated_at: '2022-10-31'
    )

    travel_to Time.zone.local(2022, 11, 6, 0, 0, 0) do
      assert_no_difference 'questioner.notifications.count' do
        mock_env('TOKEN' => 'token') do
          visit scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: 'token')
        end

        assert_user_has_no_notification(user: users(:kimura), kind: Notification.kinds[:no_correct_answer], text: 'Q&A「テストの質問」のベストアンサーがまだ選ばれていません。')
      end
    end

    travel_to Time.zone.local(2022, 11, 7, 0, 0, 0) do
      mock_env('TOKEN' => 'token') do
        visit scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: 'token')
      end

      assert_user_has_notification(user: users(:kimura), kind: Notification.kinds[:no_correct_answer], text: 'Q&A「テストの質問」のベストアンサーがまだ選ばれていません。')
    end
  end

  test 'do not notify discord when questions are updated' do
    visit_with_auth questions_path(target: 'not_solved'), 'komagata'

    click_link '質問する'
    fill_in 'question[title]', with: 'testタイトル(新規投稿)'
    fill_in 'question[description]', with: 'test本文(新規投稿)'

    mock_log = []
    stub_info = proc { |i| mock_log << i }
    Rails.logger.stub(:info, stub_info) do
      click_button '登録する'
    end

    assert_text '質問を作成しました。'
    assert_match 'Message to Discord.', mock_log.to_s

    click_link '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'testタイトル(更新)'
      fill_in 'question[description]', with: 'test本文(更新)'
    end

    mock_log = []
    Rails.logger.stub(:info, stub_info) do
      click_button '更新する'
    end

    assert_text '質問を更新しました'
    assert_no_match 'Message to Discord.', mock_log.to_s
  end
end
