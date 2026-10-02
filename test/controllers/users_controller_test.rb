# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'user card SQL does not grow with the number of displayed users' do
    template = users(:kimura).attributes.slice(*User.column_names).except('id')
    # Synthetic rows bypass signup callbacks and external services.
    # rubocop:disable Rails/SkipsModelValidations
    User.insert_all!(Array.new(4) do |index|
      template.merge('login_name' => "card-sql-#{index}", 'email' => "card-sql-#{index}@example.com")
    end)
    page = User.where('login_name LIKE ?', 'card-sql-%').order(:login_name)
    DiscordProfile.insert_all!(page.map { |user| { user_id: user.id } })
    # rubocop:enable Rails/SkipsModelValidations
    sign_in users(:komagata)
    get users_path, params: { target: 'all', search_word: 'card-sql' }
    assert_response :success

    single_queries = user_card_queries('card-sql-0')
    page_queries = user_card_queries('card-sql')

    assert_select '.users-item', count: 4
    assert_operator page_queries.size, :<=, single_queries.size + 2,
                    "SQL grew from #{single_queries.size} to #{page_queries.size}: #{page_queries.join("\n")}"
  end

  test 'user cards preserve follow labels and private talk permissions' do
    user = users(:kimura)
    viewer = users(:hajime)
    viewer.follow(user, watch: true)
    sign_in viewer
    get users_path, params: { search_word: user.login_name }
    assert_response :success
    assert_select "#follow_details#{user.id} summary", text: /コメントあり/
    assert_select '.users-item a', text: '相談部屋', count: 0

    viewer.change_watching(user, false)
    get users_path, params: { search_word: user.login_name }
    assert_select "#follow_details#{user.id} summary", text: /コメントなし/

    viewer.unfollow(user)
    get users_path, params: { search_word: user.login_name }
    assert_select "#follow_details#{user.id} summary", text: /フォローする/
  end

  test 'unauthorized target and blank search retain existing list behavior' do
    sign_in users(:hajime)
    get users_path, params: { target: 'all', search_word: ' ' }
    assert_response :success
    assert_select '.users-item', count: 0
    get users_path, params: { target: 'all' }
    assert_response :success
    assert_select '.page-main-header__title', text: /#{Regexp.escape(I18n.t('target.student_and_trainee'))}/
    assert_select '.users-item a', text: '相談部屋', count: 0
  end

  test 'user cards retain cached progress and graduate display' do
    user = users(:kimura)
    cache = ActiveSupport::Cache::MemoryStore.new
    cache.write("/model/user_course_practice/#{user.id}/completed_percentage", 12.5)
    cache.write("/model/user_course_practice/#{user.id}/completed_fraction", 'Cached progress fraction')
    sign_in users(:komagata)
    Rails.stub(:cache, cache) do
      get users_path, params: { target: 'all', search_word: user.login_name }
      assert_response :success
      assert_select '.completed-practices-progress__percentage', text: '12%'
      assert_select '.completed-practices-progress__number', text: 'Cached progress fraction'
      get users_path, params: { target: 'graduate', search_word: users(:sotugyou).login_name }
      assert_response :success
      assert_select '.completed-practices-progress__percentage', text: '100%'
      assert_select '.completed-practices-progress__number', text: '卒業'
    end
  end

  test 'user cards show only unowned tags from the tags context' do
    user = users(:kimura)
    ActsAsTaggableOn::Tagging.create!(taggable: user, tag: ActsAsTaggableOn::Tag.create!(name: 'card-owned-tag'), context: 'tags', tagger: users(:hajime))
    ActsAsTaggableOn::Tagging.create!(taggable: user, tag: ActsAsTaggableOn::Tag.create!(name: 'card-other-context-tag'), context: 'skills')
    ActsAsTaggableOn::Tagging.create!(taggable: user, tag: ActsAsTaggableOn::Tag.create!(name: 'card-visible-tag'), context: 'tags')
    sign_in users(:komagata)

    get users_path, params: { target: 'all', search_word: user.login_name }

    assert_response :success
    assert_select '.users-item .tag-links a', text: 'card-visible-tag', count: 1
    assert_select '.users-item .tag-links a', text: 'card-owned-tag', count: 0
    assert_select '.users-item .tag-links a', text: 'card-other-context-tag', count: 0
  end

  test 'POST create by student' do
    mock_env('DISCORD_GUILD_ID' => '111') do
      Card.stub(:new, -> { FakeCard.new }) do
        Subscription.stub(:new, -> { FakeSubscription.new }) do
          Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
            assert_difference 'User.students.count', 1 do
              post users_path,
                   params: {
                     user: {
                       adviser: 'false',
                       trainee: 'false',
                       company_id: '',
                       login_name: 'Piyopiyo-student',
                       email: 'piyopiyo-student@example.com',
                       name: '現役生です',
                       name_kana: 'ゲンエキセイデス',
                       description: '現役生と言います。よろしくお願いします。',
                       job: 'part_time_worker',
                       os: 'linux',
                       experiences: 0,
                       password: 'passW0rd1234',
                       password_confirmation: 'passW0rd1234',
                       coc: 1,
                       tos: 2
                     }
                   }
            end
          end
        end
      end
    end
    assert_redirected_to created_users_url(role: 'student')

    student = User.find_by(login_name: 'Piyopiyo-student')
    assert_not_nil student.discord_profile.times_id
  end

  test 'POST create by trainee' do
    mock_env('DISCORD_GUILD_ID' => '222') do
      Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
        assert_difference 'User.trainees.count', 1 do
          post users_path,
               params: {
                 user: {
                   adviser: 'false',
                   trainee: 'true',
                   company_id: '123456789',
                   login_name: 'Piyopiyo-trainee',
                   email: 'piyopiyo-trainee@example.com',
                   name: '研修生です',
                   name_kana: 'ケンシュウセイデス',
                   description: '研修生と言います。よろしくお願いします。',
                   job: 'office_worker',
                   os: 'windows_wsl2',
                   experiences: 2,
                   password: 'passW0rd1234',
                   password_confirmation: 'passW0rd1234',
                   coc: 1,
                   tos: 2
                 }
               }
        end
      end
    end
    assert_redirected_to created_users_url(role: 'trainee')

    trainee = User.find_by(login_name: 'Piyopiyo-trainee')
    assert_not_nil trainee.discord_profile.times_id
  end

  test 'POST create by adviser' do
    Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
      assert_difference 'User.advisers.count', 1 do
        post users_path,
             params: {
               user: {
                 adviser: 'true',
                 trainee: 'false',
                 company_id: '123456789',
                 login_name: 'Piyopiyo-adviser',
                 email: 'piyopiyo-adviser@example.com',
                 name: 'アドバイザーです',
                 name_kana: 'アドバイザーデス',
                 description: 'アドバイザーと言います。よろしくお願いします。',
                 password: 'passW0rd1234',
                 password_confirmation: 'passW0rd1234',
                 coc: 1,
                 tos: 2
               }
             }
      end
    end
    assert_redirected_to created_users_url(role: 'adviser')

    adviser = User.find_by(login_name: 'Piyopiyo-adviser')
    assert_nil adviser.discord_profile.times_id
  end

  test 'GET created for student' do
    get created_users_path(role: 'student')
    assert_response :success
    assert_includes response.body, 'FBC参加登録完了'
    assert_includes response.body, '参加登録が完了しました'
  end

  test 'GET created for adviser' do
    get created_users_path(role: 'adviser')
    assert_response :success
    assert_includes response.body, 'FBCアドバイザー参加登録完了'
    assert_includes response.body, 'アドバイザー登録が完了しました'
  end

  test 'GET created for trainee' do
    get created_users_path(role: 'trainee')
    assert_response :success
    assert_includes response.body, 'FBC研修生参加登録完了'
    assert_includes response.body, '研修生登録が完了しました'
  end

  test 'GET created for mentor' do
    get created_users_path(role: 'mentor')
    assert_response :success
    assert_includes response.body, 'FBCメンター参加登録完了'
    assert_includes response.body, 'メンター登録が完了しました'
  end

  test 'GET created without role defaults to student' do
    get created_users_path
    assert_response :success
    assert_includes response.body, 'FBC参加登録完了'
    assert_includes response.body, '参加登録が完了しました'
  end

  class FakeCard
    def search(*)
      nil
    end

    def create(*)
      {
        id: 'fake_customer_0123456789'
      }.stringify_keys
    end
  end

  class FakeSubscription
    def create(*)
      {
        id: 'fake_subscription_0123456789'
      }.stringify_keys
    end
  end

  class ValidTimesChannel
    def save
      true
    end

    def id
      '1234567890123456789'
    end
  end

  private

  def user_card_queries(search_word)
    queries = []
    subscriber = lambda do |*args|
      payload = args.last
      queries << payload[:sql] if payload[:sql].start_with?('SELECT') && !payload[:cached] && payload[:name] != 'SCHEMA'
    end
    ActiveRecord::Base.uncached do
      ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record') do
        get users_path, params: { target: 'all', search_word: }
      end
    end
    assert_response :success
    queries
  end
end
