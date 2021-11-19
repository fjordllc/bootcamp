require "test_helper"

class FeaturedEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get featured_entries_index_url
    assert_response :success
  end
end
