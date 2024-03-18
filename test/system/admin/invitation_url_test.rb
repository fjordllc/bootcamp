# frozen_string_literal: true

require 'application_system_test_case'

class Admin::InvitationUrlTest < ApplicationSystemTestCase
  test 'non-admin cannot be visited invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'show invitation-url page' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    assert_equal '管理ページ | FBC', title
    company = Company.order(created_at: :desc).first
    course = Course.order(:created_at).first
    assert_text "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/users/new?company_id=#{company.id}&course_id=#{course.id}&role=adviser&token=token"
  end

  test 'change selected dropdown item' do
    visit_with_auth '/admin/invitation_url', 'komagata'
    assert_equal '招待URL | FBC', title

    company = companies(:company3)
    course = courses(:course3)
    find('.js-invitation-company').click
    select(company.name)
    find('.js-invitation-role').click
    select(I18n.t('invitation_role.mentor'))
    find('.js-invitation-course')
    select(course.title)
    assert_text "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/users/new?company_id=#{company.id}&course_id=#{course.id}&role=mentor&token=token"

    company = companies(:company2)
    course = courses(:course2)
    find('.js-invitation-company').click
    select(company.name)
    find('.js-invitation-role').click
    select(I18n.t('invitation_role.trainee'))
    find('.js-invitation-course')
    select(course.title)
    assert_text "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/users/new?company_id=#{company.id}&course_id=#{course.id}&role=trainee&token=token"

    company = companies(:company1)
    course = courses(:course1)
    find('.js-invitation-company').click
    select(company.name)
    find('.js-invitation-role').click
    select(I18n.t('invitation_role.adviser'))
    find('.js-invitation-course')
    select(course.title)
    assert_text "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/users/new?company_id=#{company.id}&course_id=#{course.id}&role=adviser&token=token"
  end
end
