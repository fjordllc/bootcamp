# frozen_string_literal: true

require 'test_helper'

module Talks
  class SearchTest < ActionDispatch::IntegrationTest
    TALK_TITLE = /さんの相談部屋/

    setup do
      post user_sessions_path, params: { user: { login: 'komagata', password: 'testtest' } }
    end

    test 'search by each profile column' do
      assert_talks 2, search_word: 'kimura'

      [
        'kimuramitai', # login_name
        'Kimura Mitai', # name
        'キムラ ミタイ', # name_kana
        'kimuratwitter', # twitter_account
        'kimurafacebook', # facebook_url
        'kimurablog.org', # blog_url
        'kimuragithub', # github_account
        'kimuradiscord', # discord_account
        '木村さんに似ているとよく言われます。' # description
      ].each do |word|
        assert_talks 1, search_word: word
      end
    end

    test 'search only within the target' do
      users(:kimuramitai).update!(mentor: true)
      assert_talks 2, search_word: 'kimura'
      assert_talks 1, target: 'student_and_trainee', search_word: 'kimura' # users(:kimura)

      {
        'mentor' => ['mentor', 3, 2], # users(:mentormentaro) users(:'long-id-mentor')
        'graduate' => ['sotugyou', 3, 2], # users(:sotugyou, :sotugyou_with_job)
        'adviser' => ['advi', 3, 2],
        'trainee' => ['kensyu', 5, 3], # users(:nocompanykensyu, :kensyu, :kensyu-invoice)
        'retired' => ['yameo', 2, 1] # users(:yameo)
      }.each do |target, (word, all_count, target_count)|
        users(:kimuramitai).update!(mentor: false, login_name: "#{word}kimura")

        assert_talks all_count, search_word: word
        assert_talks target_count, target:, search_word: word
      end
    end

    test 'search within action uncompleted talks' do
      users(:kimura).talk.update!(action_completed: false)

      assert_talks 2, search_word: 'kimura'

      get talks_action_uncompleted_index_path(search_word: 'kimura')
      assert_select '.searched-talk-list .card-list-item-title__link', text: TALK_TITLE, count: 1 # users(:kimura)
    end

    test 'show searched list only when a search word is given' do
      get talks_path
      assert_select '.talk-list'
      assert_select '.searched-talk-list', false

      %w[kim ki キム キ].each do |word|
        get talks_path(search_word: word)
        assert_select '.talk-list', false, "「#{word}」で通常の一覧を出さないこと"
        assert_select '.searched-talk-list', true, "「#{word}」で検索結果の一覧を出すこと"
      end
    end

    test 'show message when no talks found' do
      get talks_path(search_word: 'hoge')

      assert_includes response.body, '一致する相談部屋はありません'
    end

    private

    def assert_talks(count, **params)
      get talks_path(params)

      assert_response :success
      assert_select 'a', { text: TALK_TITLE, count: }, "#{params}で相談部屋が#{count}件見つかること"
    end
  end
end
