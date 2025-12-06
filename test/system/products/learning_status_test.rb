# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class LearningStatusTest < ApplicationSystemTestCase
    test 'should change learning status when change wip status' do
      product = products(:product5)
      product_path = "/products/#{product.id}"
      practice_path = "/practices/#{product.practice.id}"

      visit_with_auth "#{product_path}/edit", 'kimura'
      wait_for_product_form_ready
      click_button '提出する'
      assert_text '提出物を更新しました。', wait: 10
      visit practice_path
      assert_text product.practice.title
      assert_selector 'button.is-submitted.is-active[disabled]', wait: 10

      # Phase 2: When previous_learning.status == 'started', WIP returns :started
      # because: started_practice && previous_learning.status != 'started' is false
      product.change_learning_status(:started)
      visit "#{product_path}/edit"
      wait_for_product_form_ready
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。', wait: 10
      visit practice_path
      assert_text product.practice.title
      assert_selector 'button.is-started.is-active[disabled]', wait: 10

      # Phase 3: When previous_learning.status == 'submitted' and another started practice exists,
      # WIP returns :unstarted because: started_practice && previous_learning.status != 'started' is true
      # Create another started learning for kimura
      other_product = products(:product8)
      other_product.change_learning_status(:started)

      product.change_learning_status(:submitted)
      visit product_path
      assert_selector 'input[type="submit"][value="提出する"]', wait: 10
      click_button '提出する'
      assert_text '提出物を更新しました。', wait: 10
      visit "#{product_path}/edit"
      wait_for_product_form_ready
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。', wait: 10
      visit practice_path
      assert_text product.practice.title
      assert_selector 'button.is-unstarted.is-active[disabled]', wait: 10
    end

    test 'should unchange learning status when change wip status' do
      product = products(:product8)
      product_path = "/products/#{product.id}"
      practice_path = "/practices/#{product.practice.id}"

      visit_with_auth "#{product_path}/edit", 'kimura'
      wait_for_product_form_ready
      product.change_learning_status(:started)
      visit "#{product_path}/edit"
      wait_for_product_form_ready
      click_button 'WIP'
      assert_text '提出物をWIPとして保存しました。', wait: 10
      visit practice_path

      assert_selector 'button.is-started.is-active[disabled]', wait: 10
    end

    private

    def wait_for_product_form_ready
      assert_selector 'textarea[name="product[body]"]:not([disabled])', wait: 20
    end
  end
end
