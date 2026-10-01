# frozen_string_literal: true

require 'application_system_test_case'

class MentorAiContextTest < ApplicationSystemTestCase
  test 'mentor edits their AI context' do
    visit_with_auth '/current_user/edit', 'mentormentaro'
    fill_in 'AIの応答に使う得意分野・経験', with: 'Ruby・Railsが得意です。Webアプリ開発の経験があります。'
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'

    visit '/current_user/edit'
    assert_field 'AIの応答に使う得意分野・経験', with: 'Ruby・Railsが得意です。Webアプリ開発の経験があります。'
  end

  test 'student does not see mentor AI context field' do
    visit_with_auth '/current_user/edit', 'kimura'
    assert_no_field 'AIの応答に使う得意分野・経験'
  end
end
