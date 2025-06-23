# frozen_string_literal: true

# Pull Request #4182(https://github.com/fjordllc/bootcamp/pull/4182) で Rails 7 への移行完了後に削除する
require 'application_system_test_case'

class AttachmentsTest < ApplicationSystemTestCase
  test 'attachment user avatar' do
    visit_with_auth "/users/#{users(:komagata).id}", 'komagata'
    assert_includes find('img.user-profile__user-icon-image')['src'], 'komagata.jpg'
  end

  test 'attachment company-logo in reports' do
    report = reports(:report11)
    visit_with_auth "/reports/#{report.id}", 'kensyu'
    assert_includes ['2.png', 'default.png'], File.basename(find('img.page-content-header__company-logo-image')['src'])
  end
end
