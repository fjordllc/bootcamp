# frozen_string_literal: true

require 'application_system_test_case'

class MentorProfileTest < ApplicationSystemTestCase
  test 'mentor edits their collaboration profile' do
    visit_with_auth '/current_user/edit', 'mentormentaro'
    fill_in '得意分野・プロフィール（pjord連携用）', with: 'Ruby・Railsが得意です。Webアプリ開発の経験があります。'
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'

    visit '/current_user/edit'
    assert_field '得意分野・プロフィール（pjord連携用）', with: 'Ruby・Railsが得意です。Webアプリ開発の経験があります。'
  end

  test 'student does not see mentor collaboration profile field' do
    visit_with_auth '/current_user/edit', 'kimura'
    assert_no_field '得意分野・プロフィール（pjord連携用）'
  end
end
