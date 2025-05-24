# frozen_string_literal: true

require 'test_helper'
require 'supports/product_helper'

class UserTest < ActiveSupport::TestCase
  include ProductHelper

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
    user_with_default_avatar = users(:kimura)
    assert_equal '/images/users/avatars/default.png', user_with_default_avatar.avatar_url

    user_with_custom_avatar = users(:komagata)
    assert_includes user_with_custom_avatar.avatar_url, "#{user_with_custom_avatar.login_name}.webp"
  end

  test '#generation' do
    assert_equal 1, User.new(created_at: '2013-03-25 00:00:00').generation
    assert_equal 2, User.new(created_at: '2013-05-05 00:00:00').generation
    assert_equal 6, User.new(created_at: '2014-04-10 00:00:00').generation
    assert_equal 29, User.new(created_at: '2020-01-10 00:00:00').generation
  end

  test '#practice_ids_skipped' do
    user = users(:kensyu)
    assert_includes(user.practice_ids_skipped, practices(:practice8).id)
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

  test 'notification for all' do
    target = User.notification_receiver('all')
    assert_includes(target, users(:kimura))
    assert_not_includes(target, users(:yameo))
  end

  test 'notification for students' do
    target = User.notification_receiver('students')
    assert_includes(target, users(:kimura))
    assert_includes(target, users(:komagata))
    assert_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:yameo))
    assert_not_includes(target, users(:sotugyou))
    assert_not_includes(target, users(:advijirou))
    assert_not_includes(target, users(:kensyu))
  end

  test 'notification for job_seekers' do
    target = User.notification_receiver('job_seekers')
    assert_includes(target, users(:jobseeker))
    assert_includes(target, users(:komagata))
    assert_includes(target, users(:sotugyou))
    assert_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:sotugyou_with_job))
    assert_not_includes(target, users(:kimura))
    assert_not_includes(target, users(:yameo))
  end

  test 'notification for none' do
    target = User.notification_receiver('none')
    assert_not_includes(target, users(:kimura))
    assert_not_includes(target, users(:jobseeker))
    assert_not_includes(target, users(:komagata))
    assert_not_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:sotugyou))
    assert_not_includes(target, users(:advijirou))
    assert_not_includes(target, users(:kensyu))
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

    create_checked_product(user, practice1)
    Learning.create!(
      user:,
      practice: practice1,
      status: :complete,
      created_at: (today - 2.weeks).to_formatted_s(:db),
      updated_at: (today - 2.weeks).to_formatted_s(:db)
    )

    create_checked_product(user, practice2)
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

    create_checked_product(user, practice1)
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

  test '#colleagues' do
    target = users(:kensyu).colleagues
    assert_includes(target, users(:kensyuowata))
    assert_empty users(:kimura).colleagues
  end

  test '#colleagues_other_than_self' do
    self_user = users(:kensyu)
    target = self_user.colleagues_other_than_self
    assert_includes(target, users(:kensyuowata))
    assert_not_includes(target, self_user)
  end

  test '#colleague_trainees' do
    target = users(:senpai).colleague_trainees
    assert_includes(target, users(:kensyu))
    assert_empty users(:kimura).colleague_trainees
    assert_empty users(:advijirou).colleague_trainees
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

  test '#subdivision_codes' do
    assert_equal ISO3166::Country['JP'].subdivisions.keys, users(:kimura).subdivision_codes
    assert_equal ISO3166::Country['US'].subdivisions.keys, users(:tom).subdivision_codes
    assert_empty users(:yameo).subdivision_codes
  end

  test 'country_code and subdivision_code must be valid ISO 3166-1 and 3166-2 code' do
    user = users(:hatsuno)
    user.country_code = 'invalid_country_code'
    user.subdivision_code = nil
    assert user.invalid?
    user.country_code = 'ZW' # ジンバブエ
    assert user.valid?
    user.subdivision_code = 'invalid_subdivision_code'
    assert user.invalid?
    user.subdivision_code = 'BU'
    assert user.valid?
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

  test '#cancel_participation_from_regular_events' do
    user = users(:kimura)

    assert_changes -> { RegularEventParticipation.where(user:).exists? }, from: true, to: false do
      user.cancel_participation_from_regular_events
    end
  end

  test '#delete_and_assign_new_organizer' do
    user = users(:hajime)

    assert_changes -> { Organizer.where(user:).exists? }, from: true, to: false do
      user.delete_and_assign_new_organizer
    end
  end

  test '#scheduled_retire_at' do
    assert_equal '2020-04-01 09:00:00 +0900', users(:kyuukai).scheduled_retire_at.to_s
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

  test '#area' do
    tokyo_user = users(:machida)
    america_user = users(:tom)
    no_area_user = users(:komagata)
    assert_equal tokyo_user.area, '東京都'
    assert_equal america_user.area, '米国'
    assert_nil no_area_user.area
  end

  test '.by_area' do
    tokyo_users = [users(:adminonly), users(:machida), users(:kimura)]
    assert_equal User.by_area('東京都').to_a.sort, tokyo_users.sort
    america_users = [users(:neverlogin), users(:tom)]
    assert_equal User.by_area('米国').to_a.sort, america_users.sort
  end

  test 'clear_github_data should clear GitHub related fields' do
    user = users(:kimura)
    user.github_id = '12345'
    user.github_account = 'github_kimura'
    user.github_collaborator = true
    user.save!(validate: false)

    user.clear_github_data

    assert_nil user.github_id
    assert_nil user.github_account
    assert_not user.github_collaborator
  end

  test '#latest_micro_report_page' do
    user = users(:hajime)
    assert_equal 1, user.latest_micro_report_page
    user.micro_reports.create!(Array.new(25) { |i| { content: "分報#{i + 1}" } })
    assert_equal 2, user.latest_micro_report_page
  end

  test 'convert to nil during saving when country_code and subdivision_code is empty string' do
    user = users(:hajime)
    user.country_code = ''
    user.subdivision_code = ''
    user.save!
    assert_nil user.country_code
    assert_nil user.subdivision_code
  end

  test '.job_seeking' do
    user = users(:jobseeking)
    assert_includes User.job_seeking, user
  end

  test '#mark_mail_as_sent_before_auto_retire' do
    user = users(:hajime)
    assert_not user.sent_student_before_auto_retire_mail
    user.mark_mail_as_sent_before_auto_retire
    assert user.sent_student_before_auto_retire_mail
  end
end
