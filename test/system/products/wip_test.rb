# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class WipTest < ApplicationSystemTestCase
    test 'create product as WIP' do
      visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
      within('form[name=product]') do
        fill_in('product[body]', with: 'test')
      end
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。'
      assert_text '提出物編集'
    end

    test 'update product as WIP' do
      product = products(:product1)
      visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
      within('form[name=product]') do
        fill_in('product[body]', with: 'test')
      end
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。'
      assert_text '提出物編集'
    end

    test 'update product as WIP with blank body to fail update and successfully get back to editor' do
      product = products(:product1)
      visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
      within('form[name=product]') do
        fill_in('product[body]', with: '')
      end
      click_button 'WIP'
      assert_text '本文を入力してください'
    end

    test 'user who has submitted a WIP product is alerted in the product page' do
      wip_product = products(:product5)
      visit_with_auth "/products/#{wip_product.id}", 'kimura'
      assert_text "提出物はまだ提出されていません。\n完成したら「提出する」をクリック！"
    end

    test "user is not alerted in the other's WIP product page" do
      wip_product = products(:product5)
      visit_with_auth "/products/#{wip_product.id}", 'hatsuno'
      assert_equal "提出物: #{wip_product.practice.title} | FBC", title
      assert_no_text "提出物はまだ提出されていません。\n完成したら「提出する」をクリック！"
    end

    test "Don't notify if create product as WIP" do
      visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
      within('form[name=product]') do
        fill_in('product[body]', with: 'test')
      end
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。'

      assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:watching],
                                      text: "kensyuさんが「#{practices(:practice3).title}」の提出物を提出しました。")
    end

    test "Don't notify if update product as WIP" do
      visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
      within('form[name=product]') do
        fill_in('product[body]', with: 'test')
      end
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。'

      fill_in('product[body]', with: 'test update')
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。'

      assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:watching],
                                      text: "kensyuさんが「#{practices(:practice3).title}」の提出物を提出しました。")
    end

    test 'update product to publish from WIP' do
      product = products(:product1)
      visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
      wait_for_product_form_ready
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。', wait: 10
      visit "/products/#{product.id}"
      assert_selector 'input[type="submit"][value="提出する"]', wait: 10
      click_button '提出する'
      assert_text Time.zone.now.strftime('%Y年%m月%d日')
      assert_text '提出物を更新しました。', wait: 10
    end

    test "don't show review schedule message on product page if product is WIP" do
      visit_with_auth "/products/#{products(:product5).id}", 'kimura'
      assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    end

    test 'submit-wip-submitted product does not suddenly show up as overdue' do
      visit_with_auth "/products/#{products(:product8).id}/edit", 'kimura'
      click_button 'WIP'
      click_button '提出する'
      assert_selector '.page-tabs__item-link.is-active', text: '提出物'

      visit_with_auth '/api/products/unassigned/counts.txt', 'komagata'

      assert_selector 'pre', text: '- 6日以上経過：6件'
      assert_selector 'pre', text: '- 5日経過：1件'
      assert_selector 'pre', text: '- 4日経過：1件'
    end

    test 'update published_at when update product content after wips submitted product' do
      product = products(:product5)
      product_published_at = product.published_at

      visit_with_auth "/products/#{product.id}", 'kimura'
      click_button '提出する'
      assert_text '6日以内にメンターがレビューしますので'

      assert product.reload.published_at > product_published_at
    end

    test 'return wip product page when click cancel on edit product page' do
      visit_with_auth "/products/#{products(:product5).id}/edit", 'kimura'
      click_link 'キャンセル'
      assert_selector '.page-tabs__item-link.is-active', text: '提出物'
      assert_link '内容修正'
    end

    private

    def wait_for_product_form_ready
      assert_selector 'textarea[name="product[body]"]:not([disabled])', wait: 20
    end
  end
end
