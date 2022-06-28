# frozen_string_literal: true

require 'application_system_test_case'

class AttachmentsTest < ApplicationSystemTestCase
  test 'attachment user avatar' do
    visit_with_auth "/users/#{users(:komagata).id}", 'komagata'
    assert find('img.user-profile__user-icon-image')['src'].include?('komagata.png')
    assert find('img.user-profile__company-logo')['src'].include?('1.png')
  end
end
