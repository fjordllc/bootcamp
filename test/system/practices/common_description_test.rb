# frozen_string_literal: true

require 'application_system_test_case'

module Practices
  class CommonDescriptionTest < ApplicationSystemTestCase
    test 'show common description on each page' do
      visit_with_auth "/practices/#{practices(:practice1).id}", 'hajime'
      assert_text '困った時は'
      visit "/practices/#{practices(:practice2).id}"
      assert_text '困った時は'
    end

    test 'not show common description block when practice_common_description is wip' do
      pages(:page10).update!(wip: true) # practice_common_description
      visit_with_auth "/practices/#{practices(:practice1).id}", 'hajime'
      assert_selector '.page-header__title', text: 'OS X Mountain Lionをクリーンインストールする'
      assert_no_selector '.common-page-body', text: '困った時は'
    end

    test 'not show common description block when practice_common_description does not exist' do
      pages(:page10).delete # practice_common_description
      visit_with_auth "/practices/#{practices(:practice1).id}", 'hajime'
      assert_selector '.page-header__title', text: 'OS X Mountain Lionをクリーンインストールする'
      assert_no_selector '.common-page-body', text: '困った時は'
    end

    test 'see skip practices as a trainee' do
      visit_with_auth course_practices_path(courses(:course1)), 'kensyu'
      assert_link('スキップ', href: "/practices/#{practices(:practice5).id}")
      visit_with_auth "/practices/#{practices(:practice5).id}", 'kensyu'

      assert_text 'このプラクティスはスキップしてください。'

      assert_no_selector 'label#js-complete'
    end
  end
end
