# frozen_string_literal: true

require 'test_helper'

class SearchUserTest < ActiveSupport::TestCase
  test 'ユーザーを指定しない場合' do
    kimura = users(:kimura)
    komagata = users(:komagata)
    search_user = SearchUser.new(search_word: 'kimu')
    
    searched_users = search_user.search
    assert_includes searched_users, kimura
    assert_not_includes searched_users, komagata
  end

  test '退会ユーザーを必要としない場合' do
    yameo = users(:yameo)
    search_user = SearchUser.new(search_word: 'yame', require_retire_user: false)

    assert_not_includes search_user.search, yameo
  end

  test '退会ユーザーを必要とした場合' do
    yameo = users(:yameo)
    search_user = SearchUser.new(search_word: 'yame', require_retire_user: true)

    assert_includes search_user.search, yameo
  end

  test 'targetがretiredの場合' do
    yameo = users(:yameo)
    kimura = users(:kimura)

    search_user = SearchUser.new(search_word: 'yame', target: 'retired')
    assert_includes search_user.search, yameo

    search_user = SearchUser.new(search_word: 'キム', target: 'retired')
    assert_not_includes search_user.search, kimura
  end

  test 'ユーザーを指定した時、そのユーザーの中から検索される' do
    kimura = users(:kimura)
    mentor = users(:mentormentaro)

    allowed_targets = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    users = User.users_role('mentor', allowed_targets:)

    search_user = SearchUser.new(users: , search_word: 'kimu')
    assert_not_includes search_user.search, kimura

    search_user = SearchUser.new(users: , search_word: 'メンター')
    assert_includes search_user.search, mentor
  end
end
