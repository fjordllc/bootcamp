# frozen_string_literal: true

require 'application_system_test_case'

class FollowingRequestsTest < ApplicationSystemTestCase
  %i[company profile].each do |page_type|
    test "#{page_type} keeps an unsuccessful follow retry as a create request" do
      visit_following(page_type)
      intercept_following_requests

      within_following do
        find('summary').click
        click_button 'コメントあり'
        assert_selector 'summary', text: 'フォローする'
        assert_selector 'button:disabled', count: 3

        accept_alert('フォロー処理に失敗しました') do
          page.execute_script('window.pendingFollowingRequest.fail()')
        end
        assert_selector 'button:not(:disabled)', count: 3
        assert_selector 'summary', text: 'フォローする'
        assert_not following_exists?

        open_following
        click_button 'コメントなし'
        assert_equal %w[POST POST], request_methods
        page.execute_script('window.pendingFollowingRequest.succeed()')
        assert_selector 'summary', text: 'コメントなし'
        assert following_exists?
      end
    end

    test "#{page_type} can retry following after a network error" do
      visit_following(page_type)
      intercept_following_requests

      within_following do
        find('summary').click
        click_button 'コメントあり'
        assert_selector 'button:disabled', count: 3

        accept_alert('フォロー処理に失敗しました') do
          page.execute_script('window.pendingFollowingRequest.reject()')
        end
        assert_selector 'button:not(:disabled)', count: 3
        assert_selector 'summary', text: 'フォローする'
        assert_not following_exists?

        open_following
        click_button 'コメントなし'
        assert_equal %w[POST POST], request_methods
        page.execute_script('window.pendingFollowingRequest.succeed()')
        assert_selector 'summary', text: 'コメントなし'
        assert following_exists?
      end
    end

    test "#{page_type} waits for each follow update before allowing the next operation" do
      visit_following(page_type)
      intercept_following_requests

      within_following do
        find('summary').click
        click_button 'コメントあり'
        assert_selector 'summary', text: 'フォローする'
        assert_selector 'button:disabled', count: 3
        assert_not following_exists?
        # Native clicks on disabled buttons must not send another request.
        find_button('コメントなし', disabled: true).execute_script('this.click()')
        assert_equal ['POST'], request_methods

        page.execute_script('window.pendingFollowingRequest.succeed()')
        assert_selector 'summary', text: 'コメントあり'
        assert following_record.watch?

        find('summary').click
        click_button 'コメントなし'
        assert_selector 'summary', text: 'コメントあり'
        assert_selector 'button:disabled', count: 3
        page.execute_script('window.pendingFollowingRequest.succeed()')
        assert_selector 'summary', text: 'コメントなし'
        assert_not following_record.watch?

        find('summary').click
        click_button 'フォローしない'
        assert_selector 'summary', text: 'コメントなし'
        assert_selector 'button:disabled', count: 3
        page.execute_script('window.pendingFollowingRequest.succeed()')
        assert_selector 'summary', text: 'フォローする'
        assert_not following_exists?
        assert_equal %w[POST PATCH DELETE], request_methods
      end
    end

    test "#{page_type} preserves the follow state when unfollow fails" do
      users(:kimura).follow(users(:komagata), watch: true)
      visit_following(page_type)
      intercept_following_requests

      within_following do
        find('summary').click
        click_button 'フォローしない'
        accept_alert('フォロー処理に失敗しました') do
          page.execute_script('window.pendingFollowingRequest.fail()')
        end
        assert_selector 'summary', text: 'コメントあり'
        assert_selector 'button:not(:disabled)', count: 3
        assert following_record.watch?

        open_following
        click_button 'コメントなし'
        assert_equal %w[DELETE PATCH], request_methods
        page.execute_script('window.pendingFollowingRequest.succeed()')
        assert_selector 'summary', text: 'コメントなし'
        assert_not following_record.watch?
      end
    end
  end

  private

  def visit_following(page_type)
    path = if page_type == :company
             "/companies/#{companies(:company1).id}/users?target=all"
           else
             user_path(users(:komagata))
           end
    visit_with_auth path, 'kimura'
  end

  def within_following(&)
    within("details:has(button[data-user-id='#{users(:komagata).id}']), details#follow_details#{users(:komagata).id}", &)
  end

  def open_following
    find('summary').click unless find('summary').find(:xpath, '..')['open']
  end

  def following_record
    Following.find_by!(follower: users(:kimura), followed: users(:komagata))
  end

  def following_exists?
    Following.exists?(follower: users(:kimura), followed: users(:komagata))
  end

  def request_methods
    page.evaluate_script('window.followingRequestMethods')
  end

  def intercept_following_requests
    page.execute_script <<~JS
      const originalFetch = window.fetch.bind(window)
      window.followingRequestMethods = []
      window.fetch = (url, options) => {
        if (!String(url).startsWith('/api/followings')) return originalFetch(url, options)

        window.followingRequestMethods.push(options.method)
        return new Promise((resolve, reject) => {
          window.pendingFollowingRequest = {
            fail: () => resolve(new Response(null, { status: 500 })),
            reject: () => reject(new TypeError('Failed to fetch')),
            succeed: () => originalFetch(url, options).then(resolve, reject)
          }
        })
      }
    JS
  end
end
