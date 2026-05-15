# frozen_string_literal: true

require 'application_system_test_case'

module AutoRetire
  class CleanupTest < ApplicationSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'delete unfinished data when retire' do
      user = users(:kyuukai)
      user.update!(career_path: 1)
      assert user.products.unchecked.count.positive?
      assert user.reports.wip.count.positive?

      travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
        VCR.use_cassette 'subscription/update' do
          Card.stub(:destroy_all, true) do
            mock_env('TOKEN' => 'token') do
              visit scheduler_daily_auto_retire_path(token: 'token')
            end
          end
        end
        assert_equal Date.current, user.reload.retired_on
      end

      assert_not_equal user.career_path, 1
      assert_equal 0, user.products.unchecked.count
      assert_equal 0, user.reports.wip.count
    end

    test 'delete times channel when retire' do
      user = users(:kyuukai)
      user.discord_profile.times_id = '987654321987654321'
      user.discord_profile.account_name = 'kyuukai#1234'
      user.discord_profile.save!(validate: false)

      travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
        Discord::Server.stub(:delete_text_channel, true) do
          VCR.use_cassette 'subscription/update' do
            Card.stub(:destroy_all, true) do
              mock_env('TOKEN' => 'token') do
                visit scheduler_daily_auto_retire_path(token: 'token')
              end
            end
          end
        end
        assert_equal Date.current, user.reload.retired_on
      end
      assert_nil user.discord_profile.times_id
    end

    test 'retire with invalid user status' do
      user = users(:kyuukai)
      user.twitter_account = '不正なツイッターアカウント名'
      user.save!(validate: false)
      assert user.invalid?

      travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
        VCR.use_cassette 'subscription/update' do
          Card.stub(:destroy_all, true) do
            mock_env('TOKEN' => 'token') do
              visit scheduler_daily_auto_retire_path(token: 'token')
            end
          end
        end
        assert_equal Date.current, user.reload.retired_on
      end
    end
  end
end
