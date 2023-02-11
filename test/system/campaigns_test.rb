# frozen_string_literal: true

require 'application_system_test_case'

class CampaignsTest < ApplicationSystemTestCase
  test 'check the number of participants in the campaign' do
    visit_with_auth admin_campaigns_path, 'komagata'
    assert_text '入会者'
    assert_text '現役生'
    assert_text '退会者'
  end
end
