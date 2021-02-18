require 'test_helper'

class WatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get watches_index_url
    assert_response :success
  end

end
