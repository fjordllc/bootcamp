# frozen_string_literal: true

require 'test_helper'

class Users::ListDisplayTest < ActionDispatch::IntegrationTest
  INACTIVE_MESSAGE = '.users-item__inactive-message-container.is-only-mentor .users-item__inactive-message'

  test 'admin can see link to talk on user list page' do
    login('komagata')
    get '/users'
    assert_select '.page-header__title', text: 'ユーザー'
    assert_select 'a', text: '相談部屋'
  end

  %w[mentormentaro komagata].each do |login_name|
    test "#{login_name} can see retired and hibernated tabs" do
      login(login_name)
      get '/users'
      assert_select 'a[href="/users?target=hibernated"]', text: /\A休会/
      assert_select 'a[href="/users?target=retired"]', text: /\A退会/
    end
  end

  # 見る人 => [見られる人, 自社研修生, フォローする, 登録情報変更]
  {
    'senpai sees own trainee' => ['senpai', :kensyu, true, false, false],
    'student sees trainee' => ['hatsuno', :kensyu, false, true, false],
    'senpai sees other student' => ['senpai', :hatsuno, false, true, false],
    'trainee sees myself' => ['kensyu', :kensyu, false, false, true]
  }.each do |name, (login_name, target, trainee, follow, edit)|
    test "user page when #{name}" do
      login(login_name)
      get "/users/#{users(target).id}"
      assert_response :success
      assert_equal trainee, response.body.include?('自社研修生'), '自社研修生'
      assert_equal follow, response.body.include?('フォローする'), 'フォローする'
      assert_select 'a.a-button', { text: '登録情報変更', count: edit ? 1 : 0 }, '登録情報変更'
    end
  end

  test 'shows activity counts of students, graduates and trainees' do
    login('kimura')
    [nil, 'graduate', 'trainee'].each do |target|
      get users_path(target:)
      assert_select '.card-counts__item-value', { minimum: 1 }, target.to_s
    end
  end

  test 'shows activity counts of hibernated and retired users' do
    login('komagata')
    %w[hibernated retired].each do |target|
      get users_path(target:)
      assert_select '.card-counts__item-value', { minimum: 1 }, target
    end
  end

  test 'does not show activity counts of mentors and advisers' do
    login('kimura')
    %w[mentor adviser].each do |target|
      get users_path(target:)
      assert_select '.users-item'
      assert_select '.card-counts__items', { count: 0 }, target
    end
  end

  test 'shows retirement message on retired users list' do
    login('komagata')
    get users_path(target: 'retired')
    assert_select INACTIVE_MESSAGE, text: '退会しました'
  end

  test 'shows hibernation elapsed days on hibernated users list' do
    travel_to Time.zone.local(2020, 1, 11, 0, 0, 0) do
      login('komagata')
      get users_path(target: 'hibernated')
      assert_select INACTIVE_MESSAGE, text: '休会中: 2020年01月01日〜(10日経過)'
    end
  end

  # タブ => 一覧に出てよい役割
  {
    'student_and_trainee' => %w[is-student is-trainee],
    'student' => %w[is-student]
  }.each do |target, allowed|
    test "#{target} filter lists only matching users" do
      login('komagata')
      get users_path(target:)
      assert_select 'a.tab-nav__item-link.is-active[href=?]', users_path(target:)
      roles = css_select('.users-item__icon .a-user-role')
      assert_not_empty roles
      assert(roles.all? { |role| role['class'].split.intersect?(allowed) })
    end
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end
end
