require "test_helper"

class RequireLoginTest < ActionDispatch::IntegrationTest
  test 'users_path' do
    get '/users'
    assert_redirected_to '/login'
    assert_equal 'ログインしてください', flash[:alert]
  end

  test 'questions_path' do
    get '/questions'
    assert_redirected_to '/login'
    assert_equal 'ログインしてください', flash[:alert]
  end

  test 'practices_path' do
    get '/practices'
    assert_redirected_to '/login'
    assert_equal 'ログインしてください', flash[:alert]
  end

  test 'reports_path' do
    get '/reports'
    assert_redirected_to '/login'
    assert_equal 'ログインしてください', flash[:alert]
  end

  test 'pages_path' do
    get '/pages'
    assert_redirected_to '/login'
    assert_equal 'ログインしてください', flash[:alert]
  end
end
