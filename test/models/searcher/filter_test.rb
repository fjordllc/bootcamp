# frozen_string_literal: true

require 'test_helper'

class Searcher::FilterTest < ActiveSupport::TestCase
  def setup
    @current_user = users(:komagata)
  end

  test 'initialize sets current_user and only_me' do
    filter = Searcher::Filter.new(@current_user, only_me: true)

    assert_equal @current_user, filter.current_user
    assert filter.only_me
  end

  test 'initialize defaults only_me to false' do
    filter = Searcher::Filter.new(@current_user)

    assert_not filter.only_me
  end

  test 'apply filters results by visibility' do
    filter = Searcher::Filter.new(@current_user)
    results = [users(:komagata), practices(:practice1)]

    filtered = filter.apply(results)

    assert_includes filtered, users(:komagata)
    assert_includes filtered, practices(:practice1)
  end

  test 'apply filters by user when only_me is true' do
    filter = Searcher::Filter.new(@current_user, only_me: true)
    # komagataのレポートを探す
    user_report = Report.create!(
      user: @current_user,
      title: 'Test report',
      description: 'Test description',
      reported_on: Date.current,
      emotion: 'happy'
    )
    other_user_report = reports(:report10) # hajimeのレポート
    results = [user_report, other_user_report]

    filtered = filter.apply(results)

    # 自分のレポートのみ含まれる
    assert_includes filtered, user_report
    assert_not_includes filtered, other_user_report
  end

  test 'apply removes private comments from Talk' do
    filter = Searcher::Filter.new(@current_user)
    talk = talks(:talk1)
    comment = Comment.create!(
      description: 'Private talk comment',
      user: @current_user,
      commentable: talk
    )
    results = [comment]

    filtered = filter.apply(results)

    # Talk関連のコメントは除外される
    assert_not_includes filtered, comment
  end

  test 'apply keeps regular comments' do
    filter = Searcher::Filter.new(@current_user)
    report = reports(:report1)
    comment = Comment.create!(
      description: 'Regular comment',
      user: @current_user,
      commentable: report
    )
    results = [comment]

    filtered = filter.apply(results)

    # 通常のコメントは含まれる
    assert_includes filtered, comment
  end

  test 'apply handles User objects in only_me filtering' do
    filter = Searcher::Filter.new(@current_user, only_me: true)
    current_user = users(:komagata)
    other_user = users(:hajime)
    results = [current_user, other_user]

    filtered = filter.apply(results)

    # Userオブジェクトの場合はidで比較
    assert_includes filtered, current_user
    assert_not_includes filtered, other_user
  end

  test 'apply handles objects with search_user_id method' do
    filter = Searcher::Filter.new(@current_user, only_me: true)

    # search_user_idメソッドを持つユーザーオブジェクトを使用
    current_user = users(:komagata)
    other_user = users(:hajime)

    results = [current_user, other_user]
    filtered = filter.apply(results)

    # search_user_idが現在のユーザーのIDと一致するもののみ含まれる
    assert_includes filtered, current_user
    assert_not_includes filtered, other_user
  end
end
