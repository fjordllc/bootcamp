# frozen_string_literal: true

require 'application_system_test_case'

class GenerationsTest < ApplicationSystemTestCase
  test 'no retired fileter when login without admin' do
    travel_to Time.zone.local(2022, 1, 1, 0, 0, 0) do
      visit_with_auth '/generations', 'kimura'
      assert_no_text '退会'
    end
  end

  test 'kensyu user has company link' do
    visit_with_auth generation_path(5), 'kimura'

    user = users(:kensyu)
    within('.users-item', text: user.name) do
      find("a[href*='/companies/#{user.company.id}']").click
    end
    assert_selector 'h1', text: 'Fjord inc.'
  end

  test 'hajime user has no github, discord and company link' do
    visit_with_auth generation_path(5), 'kimura'

    user = users(:hajime)
    within('.users-item', text: user.name) do
      assert_selector 'ul.sns-links__items'
      assert_selector 'li.sns-links__item', count: 5
      assert_selector 'div.is-disabled  i.fa-github-alt', visible: :all
      assert_selector 'div.is-disabled  i.fa-clock', visible: :all
      assert_no_selector "a[href*='/companies/']"
    end
  end
end
