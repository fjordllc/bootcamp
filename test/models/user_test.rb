# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '#admin?' do
    assert users(:komagata).admin?
    assert users(:machida).admin?
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
  end

  test '#prefecture_name' do
    assert_equal '未登録', users(:komagata).prefecture_name
    assert_equal '東京都', users(:kimura).prefecture_name
    assert_equal '宮城県', users(:hatsuno).prefecture_name
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

  test '#completed_percentage' do
    user = users(:komagata)
    old_percentage = user.completed_percentage
    user.completed_practices << practices(:practice5)
    assert_not_equal old_percentage, user.completed_percentage
    old_percentage = user.completed_percentage
    user.completed_practices << practices(:practice53)
    assert_equal old_percentage, user.completed_percentage
  end

  test '#reports_date_and_emotion' do
    user = users(:hajime)
    assert_equal [report: nil, date: Time.zone.today, emotion: nil], user.reports_date_and_emotion(0)
  end

  test '#depressed?' do
    user = users(:kimura)
    4.times do |i|
      report = Report.new(
        user_id: user.id, title: "test #{i}", description: 'test',
        wip: false, emotion: 'sad', reported_on: Date.current - i.days
      )
      report.learning_times << LearningTime.new(
        started_at: '2018-01-01 00:00:00', finished_at: '2018-01-01 02:00:00'
      )
      report.save!
    end
    assert user.depressed?

    report = user.reports.find_by(reported_on: Date.current)
    report.emotion = 'happy'
    report.save!
    assert_not user.depressed?
  end

  test '.order_by_counts' do
    ordered_users = User.order_by_counts('report', 'desc')
    more_report_user = users(:sotugyou)
    less_report_user = users(:yamada)
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

  test 'is valid username' do
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

  test 'discord_account' do
    user = users(:komagata)
    user.discord_account = ''
    assert user.valid?
    user.discord_account = 'komagata#1234'
    assert user.valid?
    user.discord_account = 'komagata'
    assert user.invalid?
    user.discord_account = '#1234'
    assert user.invalid?
    user.discord_account = ' komagata　#1234'
    assert user.invalid?
    user.discord_account = 'komagata1234'
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
    assert_not_includes(target, users(:yameo))
    assert_not_includes(target, users(:sotugyou))
    assert_not_includes(target, users(:yamada))
    assert_not_includes(target, users(:advijirou))
    assert_not_includes(target, users(:kensyu))
  end

  test 'announcment for job_seekers' do
    target = User.announcement_receiver('job_seekers')
    assert_includes(target, users(:jobseeker))
    assert_includes(target, users(:komagata))
    assert_not_includes(target, users(:sotugyou))
    assert_not_includes(target, users(:kimura))
    assert_not_includes(target, users(:yameo))
  end

  test '#active_practice' do
    assert_equal(users(:komagata).active_practice, practices(:practice1).id)
    assert_nil(users(:machida).active_practice)
  end

  test '#follow' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.follow(hatsuno)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
  end

  test '#unfollow' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.follow(hatsuno)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
    kimura.unfollow(hatsuno)
    assert_nil Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
  end

  test '#following' do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.following?(hatsuno)
    assert_not kimura.following?(hatsuno)
    kimura.follow(hatsuno)
    kimura.following?(hatsuno)
    assert kimura.following?(hatsuno)
  end

  test '#completed_practices_size' do
    kimura = users(:kimura)
    category2 = categories(:category2)
    assert_equal 1, kimura.completed_practices_size(category2)
  end

  test '#completed_all_practices?' do
    hajime = users(:hajime)
    category11 = categories(:category11)
    assert hajime.completed_all_practices?(category11)
  end

  test "don't unfollow user when other user unfollow user" do
    kimura = users(:kimura)
    hatsuno = users(:hatsuno)
    kimura.follow(hatsuno)
    daimyo = users(:daimyo)
    daimyo.follow(hatsuno)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
    daimyo.unfollow(hatsuno)
    assert Following.find_by(follower_id: kimura.id, followed_id: hatsuno.id)
  end

<<<<<<< HEAD
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
    komagata.update!(login_name: 'komagata1234',
                     name: 'こまがた1234',
                     name_kana: 'コマガタイチニサンヨン',
                     twitter_account: 'komagata1234_tw',
                     facebook_url: 'http://www.facebook.com/komagata1234',
                     blog_url: 'http://komagata1234.org',
                     github_account: 'komagata1234_github',
                     discord_account: 'komagata#1234',
                     description: '平日１０〜１９時勤務です。1234')
    assert_includes(User.search_by_keywords({ word: komagata.login_name, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.name, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.name_kana, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.twitter_account, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.facebook_url, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.blog_url, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.github_account, commentable_type: nil }), komagata)
    assert_includes(User.search_by_keywords({ word: komagata.discord_account, commentable_type: nil }), komagata)
  end

  test '#update_user_mentor_memo' do
    user = users(:kimura)
    params = { 'memo' => 'test' }
    user.updated_at = Time.zone.local(2020, 1, 1, 0, 0, 0)
    user.update_user_mentor_memo(user.id, params)
    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      assert user.updated_at
    end
  end
end
