# frozen_string_literal: true

require 'application_system_test_case'

class Admin::InvitationUrlTest < ApplicationSystemTestCase
  setup do
    @new_user_url = "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/users/new"
  end

  test 'non-admin cannot be visited invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'admin can be visited invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  # Memory-efficient wait for invitation URL
  # Uses JavaScript evaluation instead of repeated find() calls to avoid DOM snapshot accumulation
  def wait_for_invitation_url_with_timeout(expected)
    Capybara.using_wait_time(15) do
      page.document.synchronize(15) do
        text_value = evaluate_script("document.querySelector('.js-invitation-url-text')?.value")
        href_value = evaluate_script("document.querySelector('.js-invitation-url')?.href")
        unless text_value == expected && href_value == expected
          raise Capybara::ElementNotFound, "Expected invitation URL '#{expected}' but got text='#{text_value}', href='#{href_value}'"
        end
      end
    end
  end

  test 'show invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = Company.order(created_at: :desc).first
    role = User::INVITATION_ROLES.first[1]
    course = Course.order(:created_at).first
    expected = "#{@new_user_url}?company_id=#{company.id}&course_id=#{course.id}&role=#{role}&token=token"

    wait_for_invitation_url_with_timeout(expected)
    assert_equal expected, find('.js-invitation-url-text').value
  end

  test 'change selected company' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = companies(:company3)
    role = User::INVITATION_ROLES.first[1]
    course = Course.order(:created_at).first
    expected = "#{@new_user_url}?company_id=#{company.id}&course_id=#{course.id}&role=#{role}&token=token"

    find('.js-invitation-company').click
    select(company.name)
    wait_for_invitation_url_with_timeout(expected)
    assert_equal expected, find('.js-invitation-url-text').value
  end

  test 'change selected role' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = Company.order(created_at: :desc).first
    role_text = User::INVITATION_ROLES.second[0]
    role = User::INVITATION_ROLES.second[1]
    course = Course.order(:created_at).first
    expected = "#{@new_user_url}?company_id=#{company.id}&course_id=#{course.id}&role=#{role}&token=token"

    find('.js-invitation-role').click
    select(role_text)
    wait_for_invitation_url_with_timeout(expected)
    assert_equal expected, find('.js-invitation-url-text').value
  end

  test 'change selected course' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = Company.order(created_at: :desc).first
    role = User::INVITATION_ROLES.first[1]
    course = courses(:course2)
    expected = "#{@new_user_url}?company_id=#{company.id}&course_id=#{course.id}&role=#{role}&token=token"

    find('.js-invitation-course')
    select(course.title)
    wait_for_invitation_url_with_timeout(expected)
    assert_equal expected, find('.js-invitation-url-text').value
  end
end
