# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::SurveysTest < ApplicationSystemTestCase
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

  test 'displaying added question when choices reason for answer are required are choosed' do
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}", 'komagata'
    assert_selector 'h1', text: '【第1回】FBCモチベーションに関するアンケート'
    required_answer_checkbox = find('.survey-questions-item__checkboxes').all('.checkboxes__item')[4]
    required_answer_checkbox.select_option
    assert_text '「その他」と回答された方は、内容をお聞かせください。'
    required_answer_checkbox.select_option
    assert_no_text '「その他」と回答された方は、内容をお聞かせください。'

    required_answer_radio_button = find('.survey-questions-item__radios').all('.radios__item')[4]
    required_answer_radio_button.select_option
    assert_text '「その他」と回答された方は、内容をお聞かせください。'
    normal_radio_button = find('.survey-questions-item__radios').all('.radios__item')[0]
    normal_radio_button.select_option
    assert_no_text '「その他」と回答された方は、内容をお聞かせください。'

    required_answer_linear_scale = find('.linear-scale__points-items').first('.linear-scale__points-item')
    required_answer_linear_scale.select_option
    assert_text 'そのように回答された理由を教えてください。'
  end

  test 'displaying ended badge if a survey which deadline is over' do
    visit_with_auth '/mentor/surveys', 'komagata'
    assert_selector 'h1', text: 'アンケート一覧'

    assert_text '【第1回】FBCモチベーションに関するアンケート'
    has_text? '2020年01月01日(水) 00:00〜2020年01月01日(水) 23:59'

    assert_no_text '受付前'
    assert_no_text '受付中'
    assert_text '受付終了'
  end

  test 'creating a survey which beginning of accepting and deadline is current' do
    visit_with_auth '/mentor/surveys/new', 'komagata'

    fill_in 'アンケートのタイトル', with: '【第2回】FBCモチベーションに関するアンケート'
    fill_in 'アンケートの説明', with: 'フィヨルドブートキャンプでは満足度向上と質の高いサービスの提供に活かすためアンケートを実施しております。5分程度の簡単なアンケートです。'
    fill_in '回答受付開始日', with: Time.current.beginning_of_day
    fill_in '回答受付終了日', with: Time.current.end_of_day
    assert_text 'フィヨルドブートキャンプの学習を通して、どんなことを学びましたか？'
    click_on '保存'

    assert_text 'アンケートを作成しました。'
    assert_text '【第2回】FBCモチベーションに関するアンケート'
    assert_text '受付中'
  end

  test 'creating a survey which beginning of accepting and deadline is future' do
    visit_with_auth '/mentor/surveys/new', 'komagata'

    fill_in 'アンケートのタイトル', with: '【第3回】FBCモチベーションに関するアンケート'
    fill_in 'アンケートの説明', with: 'フィヨルドブートキャンプでは満足度向上と質の高いサービスの提供に活かすためアンケートを実施しております。5分程度の簡単なアンケートです。'
    fill_in '回答受付開始日', with: Time.current.next_year.beginning_of_day
    fill_in '回答受付終了日', with: Time.current.next_year.end_of_day
    assert_text 'フィヨルドブートキャンプの学習を通して、どんなことを学びましたか？'
    click_on '保存'

    assert_text 'アンケートを受付前として保存しました。'
    assert_text '【第3回】FBCモチベーションに関するアンケート'
    assert_text '受付前'
  end

  test 'updating a survey by adding a question' do
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}", 'komagata'
    click_on '編集'

    assert_selector 'h1', text: 'アンケート編集'
    click_on '質問を追加'
    dropdown_list_box = first('.form-item__survey-questions').all('.survey-added-question')[5].select_option.find('.choices').all('.choices__item')
    dropdown_list_box[6].select_option
    click_on '保存'

    assert_text 'アンケートを更新しました。'
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}", 'komagata'
    assert_text 'フィヨルドブートキャンプに対してご意見・ご要望がございましたら、ご自由にお書きください。'
  end

  test 'destroying a survey' do
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}", 'komagata'
    click_on '編集'

    assert_selector 'h1', text: 'アンケート編集'
    accept_confirm do
      click_link '削除する'
    end
    assert_text 'アンケートを削除しました。'
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
