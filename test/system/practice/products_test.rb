# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ProductsTest < ApplicationSystemTestCase
  test 'show listing products' do
    visit_with_auth "/practices/#{practices(:practice1).id}/products", 'komagata'
    assert_equal 'OS X Mountain Lionをクリーンインストールするの提出物 | FBC', title
  end

  test 'shows product template when product template exists' do
    practice = practices(:practice1)
    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
    assert_field 'practice_template_attributes_description', with: '提出物のテンプレート'
  end
end
