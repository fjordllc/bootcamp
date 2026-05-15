# frozen_string_literal: true

require 'application_system_test_case'

module Generations
  class TagTest < ApplicationSystemTestCase
    test 'show user tags in generation page' do
      user = users(:kimura)
      visit_with_auth generation_path(user.generation), 'kimura'

      within('.users-item', text: user.name) do
        user.tag_list.each do |tag|
          assert_text tag
        end
      end
    end

    test 'user tag links work in generation page' do
      user = users(:kimura)
      visit_with_auth generation_path(user.generation), 'kimura'

      tag_name = user.tag_list.first
      assert_text user.name
      within('.users-item', text: user.name) do
        click_link tag_name
      end
      assert_text "タグ「#{tag_name}」のユーザー"
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
