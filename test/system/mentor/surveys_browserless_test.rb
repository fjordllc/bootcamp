# frozen_string_literal: true

require 'browserless_system_test_case'

class Mentor::SurveysBrowserlessTest < BrowserlessSystemTestCase
  test 'showing questions in a show page' do
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}", 'komagata'
    assert_selector 'h1', text: '【第1回】FBCモチベーションに関するアンケート'
    assert_text 'フィヨルドブートキャンプでは満足度向上と質の高いサービスの提供に活かすためアンケートを実施しております。5分程度の簡単なアンケートです。'
    assert_text 'フィヨルドブートキャンプの学習を通して、どんなことを学びましたか？'
    assert_text 'フィヨルドブートキャンプを最初に知ったきっかけは何ですか？'
    assert_text 'フィヨルドブートキャンプを知った後にとった行動は何でしたか？（当てはまるもの全て）'
    assert_text 'なぜ、他のスクールではなくフィヨルドブートキャンプを選びましたか？'
    assert_text 'フィヨルドブートキャンプの価格設定はどのように思いますか？'
  end

  test "can't visit the show page without admin account" do
    visit_with_auth '/mentor/surveys', 'hajime'
    assert_text '管理者・メンターとしてログインしてください'
  end

  test "can't visit a show page without admin account" do
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}", 'hajime'
    assert_text '管理者・メンターとしてログインしてください'
  end

  test "can't visit an edit page without admin account" do
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}/edit", 'hajime'
    assert_text '管理者・メンターとしてログインしてください'
  end

  test "can't visit a new page without admin account" do
    visit_with_auth '/mentor/surveys/new', 'hajime'
    assert_text '管理者・メンターとしてログインしてください'
  end
end
