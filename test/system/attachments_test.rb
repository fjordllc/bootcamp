# frozen_string_literal: true

# Pull Request #4182(https://github.com/fjordllc/bootcamp/pull/4182) で Rails 7 への移行完了後に削除する
require 'application_system_test_case'

class AttachmentsTest < ApplicationSystemTestCase
  test 'attachment user avatar' do
    visit_with_auth "/users/#{users(:komagata).id}", 'komagata'
    assert find('img.user-profile__user-icon-image')['src'].include?('komagata.png')
  end

  test 'attachment company icons in reports' do
    report = reports(:report11)
    visit_with_auth "/reports/#{report.id}", 'kensyu'
    assert find('img.page-content-header__company-logo')['src'].include?('2.png')
  end
end
