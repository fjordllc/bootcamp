# frozen_string_literal: true

require 'test_helper'

class CampaignTest < ActiveSupport::TestCase
  test 'recently campaign' do
    later_campaign = campaigns(:campaign2)
    earlier_campaign = campaigns(:campaign1)

    assert_equal Campaign.recently_campaign, earlier_campaign.start_at..earlier_campaign.end_at
    assert_not_equal Campaign.recently_campaign, later_campaign.start_at..later_campaign.end_at
  end

  test 'today is campaign?' do
    campaign = campaigns(:campaign1)
    assert_equal Campaign.today_is_campaign?, (campaign.start_at..campaign.end_at).cover?(Time.zone.today)
  end
end
