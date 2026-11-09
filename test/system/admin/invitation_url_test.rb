# frozen_string_literal: true

require 'application_system_test_case'

class Admin::InvitationUrlTest < ApplicationSystemTestCase
  test 'non-admin cannot be visited invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'admin can be visited invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  def assert_invitation_url(company, role, course)
    expected = { 'company_id' => company.id.to_s, 'role' => role.to_s, 'course_id' => course.id.to_s }
    page.document.synchronize(15) do
      value, href = evaluate_script(<<~JS)
        [document.querySelector('.js-invitation-url-text')?.value,
         document.querySelector('.js-invitation-url')?.getAttribute('href')]
      JS
      query = Rack::Utils.parse_query(URI.parse(value.to_s).query)
      unless value.present? && value == href && query.except('token') == expected && RegistrationInvitation.verify(query['token']) == expected
        raise Capybara::ElementNotFound, 'Waiting for an invitation signed for the current selections'
      end
    end
    assert_equal find('.js-invitation-url-text').value, find('.js-invitation-url')['href']
  end

  test 'show invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = Company.order(created_at: :desc).first
    role = User::INVITATION_ROLES.first[1]
    course = Course.order(:created_at).first
    assert_invitation_url(company, role, course)
  end

  test 'change selected company' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = companies(:company3)
    role = User::INVITATION_ROLES.first[1]
    course = Course.order(:created_at).first
    select(company.name)
    assert_invitation_url(company, role, course)
  end

  test 'change selected role' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = Company.order(created_at: :desc).first
    role_text = User::INVITATION_ROLES.second[0]
    role = User::INVITATION_ROLES.second[1]
    course = Course.order(:created_at).first
    select(role_text)
    assert_invitation_url(company, role, course)
  end

  test 'change selected course' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    company = Company.order(created_at: :desc).first
    role = User::INVITATION_ROLES.first[1]
    course = courses(:course2)
    find('.js-invitation-course')
    select(course.title)
    assert_invitation_url(company, role, course)
  end
end
