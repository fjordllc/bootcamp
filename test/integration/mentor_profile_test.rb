# frozen_string_literal: true

require 'test_helper'

class MentorProfileIntegrationTest < ActionDispatch::IntegrationTest
  test 'mentor can save and clear their collaboration profile' do
    mentor = users(:mentormentaro)
    sign_in mentor
    patch current_user_path, params: { user: { mentor_profile: 'Ruby・Railsの設計相談が得意です。' } }
    assert_redirected_to mentor
    assert_equal 'Ruby・Railsの設計相談が得意です。', mentor.reload.mentor_profile

    patch current_user_path, params: { user: { mentor_profile: '' } }
    assert_redirected_to mentor
    assert_empty mentor.reload.mentor_profile
  end

  test 'student cannot update collaboration profile' do
    student = users(:kimura)
    sign_in student
    patch current_user_path, params: { user: { mentor_profile: 'Ruby' } }
    assert_nil student.reload.mentor_profile
  end

  test 'admin can update a mentor collaboration profile' do
    mentor = users(:mentormentaro)
    sign_in users(:komagata)
    patch admin_user_path(mentor), params: { user: { mentor_profile: 'CSSの相談に対応できます。' } }
    assert_redirected_to mentor
    assert_equal 'CSSの相談に対応できます。', mentor.reload.mentor_profile
  end
end
