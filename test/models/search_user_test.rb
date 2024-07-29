# frozen_string_literal: true

require 'test_helper'

class SearchUserTest < ActiveSupport::TestCase
  test 'no user is specified when searching' do
    kimura = users(:kimura)
    komagata = users(:komagata)
    search_user = SearchUser.new(word: 'kimu')

    searched_users = search_user.search
    assert_includes searched_users, kimura
    assert_not_includes searched_users, komagata
  end

  test 'retired user is excluded when not required' do
    yameo = users(:yameo)
    search_user = SearchUser.new(word: 'yame', require_retire_user: false)

    assert_includes search_user.search, yameo
  end

  test 'retired user is included when required' do
    yameo = users(:yameo)
    search_user = SearchUser.new(word: 'yame', require_retire_user: true)

    assert_includes search_user.search, yameo
  end

  test 'only retired users are targeted when target is retired' do
    yameo = users(:yameo)
    kimura = users(:kimura)

    search_user = SearchUser.new(word: 'yame', target: 'retired')
    assert_includes search_user.search, yameo

    search_user = SearchUser.new(word: 'キム', target: 'retired')
    assert_not_includes search_user.search, kimura
  end

  test 'search is within specified user when a user is specified' do
    kimura = users(:kimura)
    mentor = users(:mentormentaro)

    allowed_targets = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    users = User.users_role('mentor', allowed_targets:)

    search_user = SearchUser.new(word: 'kimu', users:)
    assert_not_includes search_user.search, kimura

    search_user = SearchUser.new(word: 'メンター', users:)
    assert_includes search_user.search, mentor
  end

  test 'search word is invalid when it is 2 half-width characters' do
    search_user = SearchUser.new(word: 'ki')
    assert_nil search_user.validate_search_word
  end

  test 'search word is invalid when it is 1 full-width character' do
    search_user = SearchUser.new(word: 'キ')
    assert_nil search_user.validate_search_word
  end

  test 'search word is valid when it is 3 half-width characters' do
    search_user = SearchUser.new(word: 'kim')
    assert_equal search_user.validate_search_word, 'kim'
  end

  test 'search word is valid when it is 2 full-width characters' do
    search_user = SearchUser.new(word: 'キム')
    assert_equal search_user.validate_search_word, 'キム'
  end
end
