# frozen_string_literal: true

require "test_helper"

class TimelineDecoratorTest < ActiveSupport::TestCase
  def setup
    @timeline = ActiveDecorator::Decorator.instance.decorate(timelines(:timeline_1))
  end

  test "#format_timeline_to_channel" do
    expected = %i(id description created_at updated_at user)
    assert_equal expected, @timeline.format_to_channel.keys
  end
end
