# frozen_string_literal: true

require 'test_helper'

class RegistrationInvitationTest < ActiveSupport::TestCase
  test 'signs only the issued role company and course' do
    token = RegistrationInvitation.generate(role: 'trainee_invoice_payment', company_id: 123, course_id: '456')

    assert_equal({ 'role' => 'trainee_invoice_payment', 'company_id' => '123', 'course_id' => '456' }, RegistrationInvitation.verify(token))
    assert_nil RegistrationInvitation.verify("#{token}tampered")
  end

  test 'normalizes the legacy trainee role and leaves omitted selections unbound' do
    token = RegistrationInvitation.generate(role: 'trainee')

    assert_equal({ 'role' => 'trainee_select_a_payment_method' }, RegistrationInvitation.verify(token))
  end

  test 'expires after thirty days' do
    token = RegistrationInvitation.generate(role: 'mentor')

    travel 29.days do
      assert_equal({ 'role' => 'mentor' }, RegistrationInvitation.verify(token))
    end
    travel 31.days do
      assert_nil RegistrationInvitation.verify(token)
    end
  end

  test 'rejects tokens signed for another purpose' do
    token = verifier.generate({ 'role' => 'mentor' }, purpose: :another_invitation, expires_in: 30.days)

    assert_nil RegistrationInvitation.verify(token)
  end

  test 'rejects blank malformed and legacy tokens' do
    [nil, '', ' ', 'token', {}, []].each do |token|
      assert_nil RegistrationInvitation.verify(token)
    end
  end

  test 'rejects invalid signed claims' do
    [nil, 'mentor', [], { 'role' => 'admin' }, { 'role' => 'mentor', 'admin' => true },
     { 'role' => 'mentor', 'company_id' => {} }, { 'role' => 'mentor', 'course_id' => '1invalid' }].each do |claims|
      token = verifier.generate(claims, purpose: :registration_invitation, expires_in: 30.days)
      assert_nil RegistrationInvitation.verify(token)
    end
  end

  test 'cannot issue unsupported roles or malformed IDs' do
    assert_raises(ArgumentError) { RegistrationInvitation.generate(role: 'admin') }
    assert_raises(ArgumentError) { RegistrationInvitation.generate(role: 'mentor', company_id: {}) }
    assert_raises(ArgumentError) { RegistrationInvitation.generate(role: 'mentor', course_id: '1invalid') }
  end

  private

  def verifier
    Rails.application.message_verifier(:registration_invitation)
  end
end
