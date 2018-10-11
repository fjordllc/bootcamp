# frozen_string_literal: true

require "test_helper"

class CheckTest < ActiveSupport::TestCase
  def setup
    @checked_by_komagata = checks(:report4_check_komagata)
    @checked_by_machida  = checks(:report1_check_machida)
  end

  test "Should be valid check" do
    assert @checked_by_komagata.valid?
    assert @checked_by_machida.valid?
  end

  test "Invalid check user_id blank" do
    @checked_by_komagata.user_id = ""
    assert_not @checked_by_komagata.valid?
  end

  test "Invalid check report_id blank" do
    @checked_by_komagata.checkable_id = ""
    assert_not @checked_by_komagata.valid?
  end
end
