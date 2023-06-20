# frozen_string_literal: true

require 'test_helper'

module Discord
  class TimesCategoryTest < ActiveSupport::TestCase
    setup do
      @default_times_category_id = Discord::TimesCategory.default_times_category_id
      Discord::TimesCategory.default_times_category_id = '1111111111111111111'

      @stub_times_categories = lambda { |_|
        channel_data = { 'id' => '123', 'type' => Discordrb::Channel::TYPES[:category], 'name' => 'A・B・C (ひとりごと・分報)' }
        [Discordrb::Channel.new(channel_data, nil)]
      }
    end

    teardown do
      Discord::TimesCategory.default_times_category_id = @default_times_category_id
    end

    test '.categorize_by_initials' do
      Discord::Server.stub(:categories, @stub_times_categories) do
        actual = Discord::TimesCategory.categorize_by_initials('alice🔰')
        assert_equal 123, actual
      end
    end

    test '.categorize_by_initials_with_not_matched_category' do
      Discord::Server.stub(:categories, @stub_times_categories) do
        actual = Discord::TimesCategory.categorize_by_initials('ありす🔰')
        assert_equal Discord::TimesCategory.default_times_category_id, actual
      end
    end

    test '.categorize_by_initials_with_invalid_name' do
      Discord::Server.stub(:categories, @stub_times_categories) do
        actual = Discord::TimesCategory.categorize_by_initials(nil)
        assert_equal Discord::TimesCategory.default_times_category_id, actual
      end
    end
  end
end
