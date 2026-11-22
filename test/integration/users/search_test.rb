# frozen_string_literal: true

require 'test_helper'

module Users
  class SearchTest < ActionDispatch::IntegrationTest
    setup do
      login 'komagata'
    end

    test 'search by each profile column' do
      {
        'kimura' => 'Kimura Tadasi', # login_name
        'Shinji' => 'Hatsuno Shinji', # name
        'キムラ ミタイ' => 'Kimura Mitai', # name_kana
        'hatsuno' => 'Hatsuno Shinji', # twitter_account
        'hatsuno.org' => 'Hatsuno Shinji', # blog_url
        'kananashi' => 'ユーザーです 読み方のカナが無い', # github_account
        'kimurafacebook' => 'Kimura Mitai', # facebook_url
        '木村です' => 'Kimura Tadasi' # description
      }.each do |word, name|
        get users_path(search_word: word)

        assert_response :success
        assert_select '.users-item', { text: /#{Regexp.escape(name)}/, count: 1 }, "「#{word}」で#{name}が1件見つかること"
      end
    end

    test 'search only within the target' do
      {
        'mentor' => ['machida', 'Machida Teppei'],
        'graduate' => ['卒業 就職済美', '卒業 就職済美'],
        'adviser' => ['advijirou', 'アドバイ 次郎'],
        'retired' => ['yameo', '辞目 辞目夫'],
        'trainee' => ['Kensyu Seiko', 'Kensyu Seiko']
      }.each do |target, (word, name)|
        get users_path(target:, search_word: word)
        assert_select '.users-item', { text: /#{Regexp.escape(name)}/, count: 1 }, "#{target}で#{name}が見つかること"

        get users_path(target:, search_word: 'kimura')
        assert_select '.users-item', false, "#{target}でkimuraが見つからないこと"
        assert_includes response.body, '一致するユーザーはいません'
      end
    end

    test 'search all users when target is all' do
      { 'hajime' => 'Hajime Tayo', 'machida' => 'Machida Teppei' }.each do |word, name|
        get users_path(target: 'all', search_word: word)
        assert_select '.users-item', text: /#{Regexp.escape(name)}/, count: 1
      end
    end

    test 'find retired and hibernated users when target is all' do
      %w[yameo kyuukai].each do |login_name|
        get users_path(target: 'all', search_word: login_name)
        assert_select '.users-item__header-end', text: /#{login_name}/
      end
    end

    test 'search with short words' do
      %w[mu kim ム キム].each do |word|
        get users_path(search_word: word)
        assert_select '.users-item', { text: /Kimura/, count: 2 }, "「#{word}」でKimuraが2件見つかること"
      end
    end

    test 'search form is hidden when the target has no users' do
      users(:jobseeking).update!(career_path: 0)

      get users_path(target: 'job_seeking')

      assert_select '.users-item', false
      assert_select '#js-user-search-input', false
    end

    test 'search form is shown only on the users list' do
      get users_path
      assert_select '#js-user-search-input'

      ['/generations', '/users/tags', "/users/tags/#{CGI.escape('猫')}", '/users?target=followings', '/users/companies'].each do |path|
        get path
        assert_response :success
        assert_select '#js-user-search-input', false, "#{path}に検索フォームがないこと"
      end
    end

    private

    def login(login_name)
      post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
    end
  end
end
