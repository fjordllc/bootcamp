# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '#admin?' do
    assert users(:komagata).admin?
    assert users(:machida).admin?
  end

  test '#hibernated?' do
    assert users(:kyuukai).hibernated?
    assert_not users(:hatsuno).hibernated?
  end

  test '#retired?' do
    assert users(:yameo).retired?
    assert_not users(:komagata).retired?
  end

  test '#active?' do
    travel_to Time.zone.local(2014, 1, 1, 0, 0, 0) do
      assert users(:komagata).active?
    end

    travel_to Time.zone.local(2014, 2, 2, 0, 0, 0) do
      assert_not users(:machida).active?
    end

    travel_to Time.zone.local(2022, 7, 11, 0, 0, 0) do
      assert users(:neverlogin).active? # 未ログインでも登録したばかりならactive
    end

    travel_to Time.zone.local(2022, 8, 12, 0, 0, 0) do
      assert_not users(:neverlogin).active?
    end
  end

  test '#total_learnig_time' do
    user = users(:hatsuno)
    assert_equal 0, user.total_learning_time

    report = Report.new(user_id: user.id, title: 'test', reported_on: '2018-01-01', description: 'test', wip: false)
    report.learning_times << LearningTime.new(started_at: '2018-01-01 00:00:00', finished_at: '2018-01-01 02:00:00')
    report.learning_times << LearningTime.new(started_at: '2018-01-01 23:00:00', finished_at: '2018-01-02 01:00:00')
    report.save!
    assert_equal 4, user.total_learning_time
  end

  test '#elapsed_days' do
    user = users(:komagata)
    user.created_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
    graduated_user = users(:sotugyou)
    graduated_user.created_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
    graduated_user.graduated_on = Time.zone.local(2019, 5, 31, 0, 0, 0)
    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      assert_equal 365, user.elapsed_days
      assert_equal 150, graduated_user.elapsed_days
      assert_not_equal 365, graduated_user.elapsed_days
    end
  end

  test '#avatar_url' do
    user = users(:kimura)
    assert_equal '/images/users/avatars/default.png', user.avatar_url
  end

  test '#generation' do
    assert_equal 1, User.new(created_at: '2013-03-25 00:00:00').generation
    assert_equal 2, User.new(created_at: '2013-05-05 00:00:00').generation
    assert_equal 6, User.new(created_at: '2014-04-10 00:00:00').generation
    assert_equal 29, User.new(created_at: '2020-01-10 00:00:00').generation
  end

  test '#completed_percentage don\'t calculate practice that include_progress: false' do
    user = users(:komagata)
    old_percentage = user.completed_practices_include_progress.size
    user.completed_practices << practices(:practice5)

    assert_not_equal old_percentage, user.completed_practices_include_progress.size

    old_percentage = user.completed_practices_include_progress.size
    user.completed_practices << practices(:practice53)

    assert_equal old_percentage, user.completed_practices_include_progress.size
  end

  test '#completed_percentage don\'t calculate practice unrelated cource' do
    user = users(:komagata)
    old_percentage = user.completed_practices_include_progress.size
    user.completed_practices << practices(:practice5)

    assert_not_equal old_percentage, user.completed_practices_include_progress.size

    old_percentage = user.completed_practices_include_progress.size
    user.completed_practices << practices(:practice55)

    assert_equal old_percentage, user.completed_practices_include_progress.size
  end

  test '#depressed?' do
    user = users(:kimura)

    Report.create!(
      user_id: user.id, title: 'test 1', description: 'test',
      wip: false, emotion: 'sad', reported_on: Date.current, no_learn: true
    )
    assert_not user.depressed?

    Report.create!(
      user_id: user.id, title: 'test 2', description: 'test',
      wip: false, emotion: 'sad', reported_on: 1.day.ago, no_learn: true
    )
    assert user.depressed?

    report = user.reports.find_by(reported_on: Date.current)
    report.emotion = 'happy'
    report.save!
    assert_not user.depressed?
  end

  test '.order_by_counts' do
    ordered_users = User.order_by_counts('report', 'desc')
    more_report_user = users(:sotugyou)
    less_report_user = users(:mentormentaro)
    assert ordered_users.index(more_report_user) < ordered_users.index(less_report_user)

    ordered_users = User.order_by_counts('comment', 'asc')
    more_comment_user = users(:komagata)
    less_comment_user = users(:sotugyou)
    assert ordered_users.index(less_comment_user) < ordered_users.index(more_comment_user)
  end

  test 'is valid with 8 or more characters' do
    user = users(:hatsuno)
    user.retire_reason = '辞' * 8
    assert user.save(context: :retire_reason_presence)
  end

  test 'email' do
    user = users(:kimura)
    user.email = 'abcdABCD1234@fjord.jp'
    assert user.valid?
    user.email = 'abcd.AB-CD_12/34@fjord.jp'
    assert user.valid?
    user.email = 'abcdABCD1234@fjord-fjord.jp'
    assert user.valid?
    user.email = 'abcdABCD1234.fjord.jp'
    assert user.invalid?
    user.email = 'abcd ABCD 1234@fjord.jp'
    assert user.invalid?
    user.email = '(abcdABCD1234)@fjord.jp'
    assert user.invalid?
    user.email = 'abcd@ABCD@1234@fjord.jp'
    assert user.invalid?
    user.email = 'あいうえお@fjord.jp'
    assert user.invalid?
    user.email = 'アイウエオ@fjord.jp'
    assert user.invalid?
    user.email = '１２３４５@fjord.jp'
    assert user.invalid?
    user.email = 'abcdABCD1234@.fjord.jp'
    assert user.invalid?
    user.email = 'abcdABCD1234@fjord_fjord.jp'
    assert user.invalid?
  end

  test 'login_name' do
    user = users(:komagata)
    user.login_name = 'abcdABCD1234'
    assert user.valid?
    user.login_name = 'azAZ-09'
    assert user.valid?
    user.login_name = '-abcd1234'
    assert user.invalid?
    user.login_name = 'abcd1234-'
    assert user.invalid?
    user.login_name = 'abcd--1234'
    assert user.invalid?
    user.login_name = 'abcd_1234'
    assert user.invalid?
    user.login_name = 'abcd!1234'
    assert user.invalid?
    user.login_name = 'abcd;1234'
    assert user.invalid?
    user.login_name = 'abcd:1234'
    assert user.invalid?
    user.login_name = 'あいうえお'
    assert user.invalid?
    user.login_name = 'アイウエオ'
    assert user.invalid?
    user.login_name = '１２３４５'
    assert user.invalid?
    user.login_name = 'xx'
    assert user.invalid?
  end

  test 'twitter_account' do
    user = users(:komagata)
    user.twitter_account = ''
    assert user.valid?
    user.twitter_account = 'azAZ_09'
    assert user.valid?
    user.twitter_account = '-'
    assert user.invalid?
    user.twitter_account = 'あ'
    assert user.invalid?
    user.twitter_account = ':'
    assert user.invalid?
    user.twitter_account = 'A' * 16
    assert user.invalid?
  end

  test 'is valid name_kana' do
    user = users(:komagata)
    user.name_kana = 'コマガタ マサキ'
    assert user.valid?
    user.name_kana = 'コマガタ　マサキ'
    assert user.valid?
    user.name_kana = '駒形 真幸'
    assert user.invalid?
    user.name_kana = 'こまがた まさき'
    assert user.invalid?
    user.name_kana = 'グエンテーヴィン'
    assert user.valid?
    user.name_kana = 'komagata masaki'
    assert user.invalid?
    user.name_kana = '-'
    assert user.invalid?
    user.name_kana = ''
    assert user.invalid?
  end

  test 'announcment for all' do
    target = User.announcement_receiver('all')
    assert_includes(target, users(:kimura))
    assert_not_includes(target, users(:yameo))
  end

  test 'announcment for students' do
    target = User.announcement_receiver('students')
    assert_includes(target, users(:kimura))
    assert_includes(target, users(:komagata))
    assert_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:yameo))
    assert_not_includes(target, users(:sotugyou))
    assert_not_includes(target, users(:advijirou))
    assert_not_includes(target, users(:kensyu))
  end

  test 'announcment for job_seekers' do
    target = User.announcement_receiver('job_seekers')
    assert_includes(target, users(:jobseeker))
    assert_includes(target, users(:komagata))
    assert_includes(target, users(:sotugyou))
    assert_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:sotugyou_with_job))
    assert_not_includes(target, users(:kimura))
    assert_not_includes(target, users(:yameo))
  end

  test '#follow' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.follow(hatsuno, watch: true)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id, watch: true)
  end

  test '#change_watching' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.follow(hatsuno, watch: true)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id, watch: true)
    kimura.change_watching(hatsuno, false)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id, watch: false)
  end

  test '#unfollow' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.follow(hatsuno, watch: true)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
    kimura.unfollow(hatsuno)
    assert_nil Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
  end

  test '#following' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.following?(hatsuno)
    assert_not kimura.following?(hatsuno)
    kimura.follow(hatsuno, watch: true)
    kimura.following?(hatsuno)
    assert kimura.following?(hatsuno)
  end

  test '#auto_watching' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.following?(hatsuno)
    assert_not kimura.watching?(hatsuno)
    kimura.follow(hatsuno, watch: false)
    kimura.following?(hatsuno)
    assert_not kimura.watching?(hatsuno)
    kimura.change_watching(hatsuno, true)
    kimura.following?(hatsuno)
    assert kimura.watching?(hatsuno)
  end

  test '#followees_list ' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    hajime = users(:hajime)
    mentormentaro = users(:mentormentaro)
    kimura.follow(hatsuno, watch: true)
    kimura.follow(hajime, watch: true)
    kimura.follow(mentormentaro, watch: false)
    assert_equal 3, kimura.followees_list.count
    assert_equal 2, kimura.followees_list(watch: 'true').count
    assert_equal 1, kimura.followees_list(watch: 'false').count
  end

  test '#completed_practices_size_by_category' do
    kimura = users(:kimura)
    category2 = categories(:category2)
    assert_equal 1, kimura.completed_practices_size_by_category[category2.id]
  end

  test "don't unfollow user when other user unfollow user" do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.follow(hatsuno, watch: true)
    hajime = users(:hajime)
    hajime.follow(hatsuno, watch: true)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
    hajime.unfollow(hatsuno)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
  end

  test "don't return retired user data" do
    yameo = users(:yameo)
    result = Searcher.search(yameo.name)
    assert_not_includes(result, yameo)
  end

  test 'return not retired user data' do
    hajime = users(:hajime)
    result = Searcher.search(hajime.name)
    assert_includes(result, hajime)
  end

  test 'columns_for_keyword_searchの設定がsearch_by_keywordsに反映されていることを確認' do
    komagata = users(:komagata)
    komagata.discord_profile.account_name = 'komagata1234'
    komagata.update!(login_name: 'komagata1234',
                     name: 'こまがた1234',
                     name_kana: 'コマガタイチニサンヨン',
                     twitter_account: 'komagata1234_tw',
                     facebook_url: 'http://www.facebook.com/komagata1234',
                     blog_url: 'http://komagata1234.org',
                     github_account: 'komagata1234_github',
                     description: '平日１０〜１９時勤務です。1234')
    assert_includes(User.search_by_keywords({ word: komagata.login_name, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.name, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.name_kana, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.twitter_account, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.facebook_url, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.blog_url, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.github_account, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.discord_profile.account_name, commentable_type: nil }), komagata)
  end

  test '#update_user_mentor_memo' do
    user = users(:kimura)
    assert_equal 'kimuraさんのメモ', user.mentor_memo
    user.updated_at = Time.zone.local(2020, 1, 1, 0, 0, 0)
    user.update_mentor_memo('新規メモ')
    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      assert user.updated_at
    end
    assert_equal '新規メモ', user.mentor_memo
  end

  test '.delayed when there are users within 2 weeks from completion of last practice' do
    user = users(:nippounashi)
    practice1 = practices(:practice1)
    practice2 = practices(:practice2)
    today = Time.zone.today

    Learning.create!(
      user:,
      practice: practice1,
      status: :complete,
      created_at: (today - 2.weeks).to_formatted_s(:db),
      updated_at: (today - 2.weeks).to_formatted_s(:db)
    )

    Learning.create!(
      user:,
      practice: practice2,
      status: :complete,
      created_at: (today - (2.weeks + 1.day)).to_formatted_s(:db),
      updated_at: (today - (2.weeks + 1.day)).to_formatted_s(:db)
    )

    worried_users = User.delayed.order(completed_at: :asc)

    assert_equal worried_users.where(id: user.id).size, 1
    assert_equal worried_users.find(user.id).id, user.id
  end

  test '.delayed when there are users within less than 2 weeks from completion of last practice' do
    user = users(:nippounashi)
    today = Time.zone.today

    Learning.create!(
      user:,
      practice: Practice.first,
      status: :complete,
      created_at: (today - (2.weeks - 1.day)).to_formatted_s(:db),
      updated_at: (today - (2.weeks - 1.day)).to_formatted_s(:db)
    )

    worried_users = User.delayed.order(completed_at: :asc)

    assert_equal worried_users.where(id: user.id).size, 0
  end

  test '.delayed when there are graduate users within 2 weeks from completion of last practice' do
    user = users(:nippounashi)
    practice1 = practices(:practice1)
    today = Time.zone.today

    Learning.create!(
      user:,
      practice: practice1,
      status: :complete,
      created_at: (today - 2.weeks).to_formatted_s(:db),
      updated_at: (today - 2.weeks).to_formatted_s(:db)
    )

    worried_users = User.delayed.order(completed_at: :asc)
    assert_equal worried_users.where(id: user.id).size, 1
    assert_equal worried_users.find(user.id).id, user.id

    user.graduated_on = today
    user.save!

    worried_users = User.delayed.order(completed_at: :asc)
    assert_equal worried_users.where(id: user.id).size, 0
  end

  test 'get category active or unstarted practice' do
    komagata = users(:komagata)
    assert_equal 917_504_053, komagata.category_active_or_unstarted_practice.id

    machida = users(:machida)
    practice1 = practices(:practice1)
    Learning.create!(
      user: machida,
      practice: practice1,
      status: :complete
    )
    assert_equal 685_020_562, machida.category_active_or_unstarted_practice.id
  end

  test 'trainee must select company' do
    user = users(:kensyu)
    user.company_id = nil
    assert user.invalid?
  end

  test '.depressed_reports' do
    assert_equal 1, User.depressed_reports.size
  end

  test '#wip_exists?' do
    user = users(:machida)
    assert_not user.wip_exists?

    Report.create!(user_id: user.id, title: 'WIP test', description: 'WIP test', wip: true, reported_on: Time.current)
    assert user.wip_exists?
  end

  test '#raw_last_sad_report_id' do
    assert_equal \
      users(:komagata).reports.order(reported_on: :desc).limit(1).pick(:id),
      users(:komagata).raw_last_sad_report_id
  end

  test 'students_and_trainees_method_does_not_include_retired_trainee' do
    target = User.students_and_trainees
    assert_includes(target, users(:kensyu))
    users(:kensyu).update!(retired_on: '2022-07-01')
    assert_not_includes(target, users(:kensyu))
  end

  test 'students_and_trainees_method_does_not_include_graduates' do
    target = User.students_and_trainees
    assert_not_includes(target, users(:sotugyou_with_job))
  end

  test '#retired_students' do
    target = User.retired_students
    assert_includes(target, users(:yameo))
    assert_not_includes(target, users(:kensyuowata))
  end

  test '.year_end_party' do
    target = User.year_end_party
    assert_not_includes(target, users(:kyuukai))
    assert_not_includes(target, users(:yameo))
    assert_includes(target, users(:kimura))
  end

  test '#belongs_company_and_adviser?' do
    assert_not users(:kensyu).belongs_company_and_adviser?
    assert_not users(:advijirou).belongs_company_and_adviser?
    assert users(:senpai).belongs_company_and_adviser?
  end

  test '#collegues' do
    target = users(:kensyu).collegues
    assert_includes(target, users(:kensyuowata))
    assert_nil users(:kimura).collegues
  end

  test '#collegue_trainees' do
    target = users(:senpai).collegue_trainees
    assert_includes(target, users(:kensyu))
    assert_nil users(:kimura).collegue_trainees
    assert_nil users(:advijirou).collegue_trainees
  end

  test '#after_twenty_nine_days_registration?' do
    over29days_registered_student = User.create!(
      login_name: 'thirty',
      email: 'thirty@fjord.jp',
      password: 'testtest',
      name: '入会 三十郎',
      name_kana: 'ニュウカイ サンジュウロウ',
      description: '入会30日経過したユーザーです',
      course: courses(:course1),
      job: 'student',
      os: 'mac',
      experience: 'ruby',
      created_at: Time.current - 30.days,
      sent_student_followup_message: false
    )
    recently_registered_student = User.create!(
      login_name: 'recently',
      email: 'recently_registered_student@fjord.jp',
      password: 'testtest',
      name: '入会 太郎',
      name_kana: 'ニュウカイ タロウ',
      description: '最近入会したユーザーです',
      course: courses(:course1),
      job: 'student',
      os: 'mac',
      experience: 'ruby',
      created_at: Time.current,
      sent_student_followup_message: false
    )

    assert over29days_registered_student.after_twenty_nine_days_registration?
    assert_not recently_registered_student.after_twenty_nine_days_registration?
  end

  test '#followup_message_target?' do
    target = User.create!(
      login_name: 'thirty',
      email: 'thirty@fjord.jp',
      password: 'testtest',
      name: '入会 三十郎',
      name_kana: 'ニュウカイ サンジュウロウ',
      description: '入会30日経過したユーザーです',
      course: courses(:course1),
      job: 'student',
      os: 'mac',
      experience: 'ruby',
      hibernated_at: nil,
      created_at: Time.current - 30.days,
      sent_student_followup_message: false
    )
    nottarget = users(:komagata)
    otameshi = users(:otameshi)
    hibernated = users(:kyuukai)
    assert target.followup_message_target?
    assert_not nottarget.followup_message_target?
    assert_not otameshi.followup_message_target?
    assert_not hibernated.followup_message_target?
  end

  test '#mark_message_as_sent_for_hibernated_student' do
    User.mark_message_as_sent_for_hibernated_student

    assert_not users(:komagata).sent_student_followup_message
    assert users(:kyuukai).sent_student_followup_message
  end

  test '#sent_student_followup_message' do
    target = User.create!(
      login_name: 'thirty',
      email: 'thirty@fjord.jp',
      password: 'testtest',
      name: '入会 三十郎',
      name_kana: 'ニュウカイ サンジュウロウ',
      description: '入会30日経過したユーザーです',
      course: courses(:course1),
      job: 'student',
      os: 'mac',
      experience: 'ruby',
      hibernated_at: nil,
      created_at: Time.current - 30.days,
      sent_student_followup_message: false
    )

    User.create_followup_comment(target)

    assert target.sent_student_followup_message
  end

  test '#hibernation_elapsed_days' do
    user = users(:kyuukai)

    travel_to Time.zone.local(2020, 1, 10) do
      elapsed_days = user.hibernation_elapsed_days

      assert assert_equal 9, elapsed_days
    end
  end

  test '#country_name' do
    assert_equal '日本', users(:kimura).country_name
    assert_equal '米国', users(:tom).country_name
  end

  test '#subdivision_name' do
    assert_equal '東京都', users(:kimura).subdivision_name
    assert_equal 'ニューヨーク州', users(:tom).subdivision_name
  end

  test '#create_comebacked_comment' do
    hajime = users(:hajime)
    comment =
      assert_difference 'Comment.count', 1 do
        hajime.create_comebacked_comment
      end
    description = "お帰りなさい！！復会ありがとうございます。\n" \
           '休会中に何か変わったことがあれば、再びスムーズに学び始めることができるように全力でサポートします。' \
           "何か困ったことや質問があれば、メンターの皆さんに遠慮なくご相談ください。\n\n" \
           "またフィヨルドブートキャンプの Discord のサーバーに入室できるように、再度、Doc にある Discord の招待 URL にアクセスをお願いします。\n" \
           '<https://bootcamp.fjord.jp/practices/129#url>'
    assert_equal hajime.id, comment.commentable.user_id
    assert_equal users(:pjord).id, comment.user_id
    assert_equal description, comment.body
  end

  test '#become_watcher!' do
    watchable = pages(:page1)
    user = users(:kimura)

    assert_not user.watches.exists?(watchable:)

    user.become_watcher!(watchable)
    assert user.watches.exists?(watchable:)
  end

  test '.users_role' do
    allowed_targets = %w[student_and_trainee mentor graduate adviser trainee year_end_party]

    # target引数とdefault_target引数に関して、targetとscope名が一致しているケースと一致していないケースを順にテストする
    assert_equal User.mentor, User.users_role('mentor', allowed_targets:, default_target: 'student_and_trainee')
    assert_equal User.graduated, User.users_role('graduate', allowed_targets:, default_target: 'student_and_trainee')

    assert_equal User.year_end_party, User.users_role('', allowed_targets:, default_target: 'year_end_party')
    assert_equal User.students_and_trainees, User.users_role('', allowed_targets:, default_target: 'student_and_trainee')
  end

  test '.users_role returns default_target when invalid target is passed' do
    allowed_targets = %w[student_and_trainee mentor graduate adviser trainee year_end_party]
    not_allowed_target = 'retired'
    assert_equal User.students_and_trainees, User.users_role(not_allowed_target, allowed_targets:, default_target: 'student_and_trainee')
    not_scope_name = 'destroy_all'
    assert_equal User.students_and_trainees, User.users_role(not_scope_name, allowed_targets:, default_target: 'student_and_trainee')
    assert_empty User.users_role(not_scope_name, allowed_targets:)
  end

  test '#delete_and_assign_new_organizer' do
    user = users(:hajime)

    assert_changes -> { Organizer.where(user:).exists? }, from: true, to: false do
      user.delete_and_assign_new_organizer
    end
  end

  test '#scheduled_retire_at' do
    assert_equal '2020-07-01 09:00:00 +0900', users(:kyuukai).scheduled_retire_at.to_s
    assert_nil users(:hatsuno).scheduled_retire_at
  end

  test '.users_job' do
    assert_equal User.job_student, User.users_job('student')
    assert_equal User.job_office_worker, User.users_job('office_worker')
    assert_equal User.job_part_time_worker, User.users_job('part_time_worker')
    assert_equal User.job_vacation, User.users_job('vacation')
    assert_equal User.job_unemployed, User.users_job('unemployed')
  end

  test '.users_job returns all users when invalid job is passed' do
    assert_equal User.all, User.users_job('destroy_all')
  end
end
