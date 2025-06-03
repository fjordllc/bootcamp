# frozen_string_literal: true

require 'application_system_test_case'

class ProductNotificationsTest < ApplicationSystemTestCase
  test 'display learning completion message when a user of the completed product visits show first time' do
    visit_with_auth "/products/#{products(:product65).id}", 'kimura'
    assert_text '喜びをXにポストする！'
  end

  test 'not display learning completion message when a user of the completed product visits after the second time' do
    visit_with_auth "/products/#{products(:product65).id}", 'komagata'
    click_button '提出物を合格にする'
    assert_text '提出物の合格を取り消す'
    visit_with_auth "/products/#{products(:product65).id}", 'kimura'
    first('label.card-main-actions__muted-action.is-closer').click
    assert_no_text '喜びをXにポストする！'
    visit current_path
    assert_text 'Xに修了ポストする'
    assert_no_text '喜びをXにポストする！'
  end

  test 'not display learning completion message when a user whom the product does not belongs to visits show' do
    visit_with_auth "/products/#{products(:product65).id}", 'yamada'
    assert_no_text '喜びをXにポストする！'
  end

  test 'not display learning completion message when a user of the non-completed product visits show' do
    visit_with_auth "/products/#{products(:product6).id}", 'sotugyou'
    assert_no_text '喜びをXにポストする！'
  end

  test "Don't notify if create product as WIP" do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_no_text "kensyuさんが「#{practices(:practice3).id}」の提出物を提出しました。"
  end

  test "Don't notify if update product as WIP" do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    fill_in('product[body]', with: 'test update')
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_no_text "kensyuさんが「#{practices(:practice3).title}」の提出物を提出しました。"
  end

  test "should add to trainer's watching list when trainee submits product" do
    users(:senpai).watches.delete_all

    visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
    within('form[name=product]') do
      fill_in('product[body]', with: '研修生が提出物を提出すると、その企業のアドバイザーのWatch中に登録される')
    end
    click_button '提出する'
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    visit_with_auth '/current_user/watches', 'senpai'
    assert_text '研修生が提出物を提出すると、その企業のアドバイザーのWatch中に登録される'
  end

  test 'show review schedule message on product page' do
    visit_with_auth "/products/#{products(:product8).id}", 'kimura'
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end

  test "don't show review schedule message on product page if mentor comments" do
    visit_with_auth "/products/#{products(:product10).id}", 'kimura'
    assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end

  test "don't show review schedule message on product page if product is checked" do
    visit_with_auth "/products/#{products(:product2).id}", 'kimura'
    assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end

  test "don't show review schedule message on product page if product is WIP" do
    visit_with_auth "/products/#{products(:product5).id}", 'kimura'
    assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end
end
