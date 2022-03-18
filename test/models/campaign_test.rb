# frozen_string_literal: true

require 'test_helper'

class CampaignTest < ActiveSupport::TestCase
  test 'recently campaign' do
    past_campaign = campaigns(:campaign2)
    current_campaign = campaigns(:campaign1)

    assert_equal Campaign.recently_campaign, current_campaign.start_at..current_campaign.end_at
    assert_not_equal Campaign.recently_campaign, past_campaign.start_at..past_campaign.end_at
  end

  test 'today is campaign?' do
    campaign = campaigns(:campaign1)
    assert_equal Campaign.today_campaign?, (campaign.start_at..campaign.end_at).cover?(Time.current)
  end
end
