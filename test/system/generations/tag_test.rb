# frozen_string_literal: true

require 'application_system_test_case'

module Generations
  class TagTest < ApplicationSystemTestCase
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
  end
end
