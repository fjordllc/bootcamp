require 'test_helper'

class OauthsControllerTest < ActionController::TestCase
  test "should get oauth" do
    get :oauth
    assert_response :success
  end

  test "should get callback" do
    get :callback
    assert_response :success
  end

end
