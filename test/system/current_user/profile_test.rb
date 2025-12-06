# frozen_string_literal: true

require 'application_system_test_case'

module CurrentUser
  class ProfileTest < ApplicationSystemTestCase
    test 'general users cannot update their profiles' do
      visit_with_auth '/current_user/edit', 'kimura'
      assert_no_text 'プロフィール'
      assert_no_text 'プロフィール画像'
      assert_no_text 'プロフィール名'
      assert_no_text 'プロフィール文'
    end

    test 'mentors can update their profiles' do
      visit_with_auth '/current_user/edit', 'komagata'
      assert_text 'プロフィール'
      assert_text 'プロフィール画像'
      assert_text 'プロフィール名'
      assert_text 'プロフィール文'
    end

    test 'do not show after graduation hope when advisor or mentor' do
      visit_with_auth '/current_user/edit', 'hajime'
      assert_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
      visit_with_auth '/current_user/edit', 'senpai'
      assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
      visit_with_auth '/current_user/edit', 'mentormentaro'
      assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
    end
  end
end
