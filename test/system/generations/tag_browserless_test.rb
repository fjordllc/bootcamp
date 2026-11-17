# frozen_string_literal: true

require 'browserless_system_test_case'

module Generations
  class TagBrowserlessTest < BrowserlessSystemTestCase
    test 'show user tags in generation page' do
      user = users(:kimura)
      visit_with_auth generation_path(user.generation), 'kimura'

      within('.users-item', text: user.name) do
        user.tag_list.each do |tag|
          assert_text tag
        end
      end
    end

    test 'user tags display with correct CSS classes in generation page' do
      user = users(:kimura)
      visit_with_auth generation_path(user.generation), 'kimura'

      within('.users-item', text: user.name) do
        assert_selector '.tag-links'
        assert_selector '.tag-links__items'
        assert_selector '.tag-links__item'
        assert_selector '.tag-links__item-link'
      end
    end

    test 'user without tags does not show tag-links in generation page' do
      user = users(:otameshi)
      assert_empty user.tag_list

      visit_with_auth generation_path(user.generation), 'otameshi'

      within('.users-item', text: user.name) do
        assert_no_selector '.tag-links'
      end
    end
  end
end
