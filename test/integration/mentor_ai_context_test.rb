# frozen_string_literal: true

require 'test_helper'

class MentorAiContextIntegrationTest < ActionDispatch::IntegrationTest
  test 'mentor can save and clear their AI context' do
    mentor = users(:mentormentaro)
    sign_in mentor
    patch current_user_path, params: { user: { mentor_ai_context: 'Ruby・Railsの設計相談が得意です。' } }
    assert_redirected_to mentor
    assert_equal 'Ruby・Railsの設計相談が得意です。', mentor.reload.mentor_ai_context

    patch current_user_path, params: { user: { mentor_ai_context: '' } }
    assert_redirected_to mentor
    assert_empty mentor.reload.mentor_ai_context
  end

  test 'student cannot update AI context' do
    student = users(:kimura)
    sign_in student
    patch current_user_path, params: { user: { mentor_ai_context: 'Ruby' } }
    assert_nil student.reload.mentor_ai_context
  end

  test 'admin can update a mentor AI context' do
    mentor = users(:mentormentaro)
    sign_in users(:komagata)
    patch admin_user_path(mentor), params: { user: { mentor_ai_context: 'CSSの相談に対応できます。' } }
    assert_redirected_to mentor
    assert_equal 'CSSの相談に対応できます。', mentor.reload.mentor_ai_context
  end

  test 'AI context is not exposed on user pages or the users API' do
    mentor = users(:mentormentaro)
    mentor.update!(mentor_ai_context: 'AI連携のためだけの経歴と得意分野')
    sign_in users(:kimura)

    get user_path(mentor)
    assert_response :success
    assert_not_includes response.body, mentor.mentor_ai_context

    get api_user_path(mentor, format: :json)
    assert_response :success
    assert_not_includes response.parsed_body.keys, 'mentor_ai_context'
    assert_not_includes response.body, mentor.mentor_ai_context
  end
end
