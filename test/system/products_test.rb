# frozen_string_literal: true

require 'application_system_test_case'

class ProductsTest < ApplicationSystemTestCase
  test 'can not see tweet button when current_user does not complete a practice' do
    visit_with_auth "/products/#{products(:product1).id}", 'yamada'
    assert_no_text 'Xに修了ポストする'
  end

  test 'display learning completion message when a user of the completed product visits show first time' do
    visit_with_auth "/products/#{products(:product65).id}", 'kimura'
    assert_text '喜びをXにポストする！'
  end

  test 'not display learning completion message when a user of the completed product visits after the second time' do
    visit_with_auth "/products/#{products(:product65).id}", 'komagata'
    click_button '提出物を合格にする'
    assert_button '提出物の合格を取り消す'
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

  test 'can see tweet button when current_user has completed a practice' do
    visit_with_auth "/products/#{products(:product2).id}", 'kimura'
    assert_text 'Xに修了ポストする'

    find('.a-button.is-tweet').click
    assert_text '喜びをXにポストする！'
  end

  test 'create product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    assert_text 'Watch中'
  end

  test 'should change messages when submit product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'hatsuno'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    visit "/practices/#{practices(:practice6).id}"
    assert_equal first('.test-product').text, '提出物へ'
  end

  test 'update product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text '提出物を更新しました。'
  end

  test 'update product after checked' do
    my_product = products(:product2)
    others_product = products(:product15)
    visit_with_auth "/products/#{my_product.id}/edit", 'kimura'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'

    visit "/products/#{others_product.id}"
    assert_current_path("/products/#{others_product.id}")
  end

  test 'delete product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'mentormentaro'
    accept_confirm do
      click_link '削除'
    end
    assert_text '提出物を削除しました'
  end

  test 'product has a comment form ' do
    product = ensure_valid_product(products(:product1))
    visit_with_auth "/products/#{product.id}", 'mentormentaro'
    wait_for_comment_form
    assert_selector '.thread-comment-form'
  end

  test 'products order on all tab' do
    Product.update_all(created_at: 1.day.ago, published_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
    # 最新と最古の提出物を画面上で判定するため、提出物を1ページ内に収める
    Product.limit(Product.count - Product.default_per_page).delete_all
    newest_product = Product.reorder(:id).first
    newest_product.update(published_at: Time.current)
    newest_product_decorated_author = ActiveDecorator::Decorator.instance.decorate(newest_product.user)
    oldest_product = Product.reorder(:id).last
    oldest_product_decorated_author = ActiveDecorator::Decorator.instance.decorate(oldest_product.user)
    oldest_product.update(published_at: 2.days.ago)

    visit_with_auth '/products', 'komagata'

    # 提出日の新しい順で並んでいることを検証する
    titles = all('.card-list-item-title__title').map { |t| t.text.delete('★') }
    names = all('.card-list-item-meta .a-user-name').map(&:text)
    assert_equal "#{newest_product.practice.title}の提出物", titles.first
    assert_equal newest_product_decorated_author.long_name, names.first
    assert_equal "#{oldest_product.practice.title}の提出物", titles.last
    assert_equal oldest_product_decorated_author.long_name, names.last
  end

  test 'show user name_kana next to name' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'kimura'
    user = product.user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    assert_text decorated_user.long_name
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

  test 'show number of comments' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    within(:css, '.is-emphasized') do
      assert_text '2'
    end
  end

  test 'not update published_at when update product content after submitted product' do
    product = products(:product12)
    product_published_at = product.published_at

    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    click_button '提出する'

    assert product.reload.published_at = product_published_at
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'return practice page when click cancel on new product page' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice1).id}", 'hatsuno'
    click_link 'キャンセル'
    assert_selector '.page-tabs__item-link.is-active', text: 'プラクティス'
    assert_link '提出物を作る'
  end

  private

  def wait_for_product_form_ready
    assert_selector 'textarea[name="product[body]"]:not([disabled])', wait: 20
  end
end
