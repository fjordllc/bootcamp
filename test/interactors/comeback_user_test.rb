# frozen_string_literal: true

require 'test_helper'

class ComebackUserTest < ActiveSupport::TestCase
  test 'skips subscription in staging environment' do
    user = users(:kyuukai)

    original_db_name = ENV['DB_NAME']
    ENV['DB_NAME'] = 'bootcamp_staging'

    Rails.env.stub(:production?, true) do
      assert_nothing_raised do
        ComebackUser.call(user:)
      end
    end

    assert_nil user.reload.hibernated_at
  ensure
    ENV['DB_NAME'] = original_db_name
  end
end
