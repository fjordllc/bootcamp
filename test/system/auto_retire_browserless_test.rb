# frozen_string_literal: true

require 'browserless_system_test_case'

class AutoRetireBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'not retire when hibernated for less than three months' do
    user = users(:kyuukai)
    travel_to Time.zone.local(2020, 4, 1, 0, 0, 0) do
      VCR.use_cassette 'subscription/update' do
        Card.stub(:destroy_all, true) do
          mock_env('TOKEN' => 'token') do
            visit scheduler_daily_auto_retire_path(token: 'token')
          end
        end
      end
      assert_nil user.reload.retired_on
    end
  end

  test 'do nothing with already retired user' do
    user = users(:kyuukai)

    retired_date = Date.new(2020, 4, 1)
    user.update!(retired_on: retired_date)

    travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
      mock_env('TOKEN' => 'token') do
        visit scheduler_daily_auto_retire_path(token: 'token')
      end
      assert_equal retired_date, user.reload.retired_on
    end
  end
end
