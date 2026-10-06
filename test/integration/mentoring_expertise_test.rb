# frozen_string_literal: true

require 'test_helper'

class MentoringExpertiseIntegrationTest < ActionDispatch::IntegrationTest
  test 'mentor can save and clear their mentoring expertise' do
    mentor = users(:mentormentaro)
    sign_in mentor
    patch current_user_path, params: { user: { mentoring_expertise: 'Ruby・Railsの設計相談が得意です。' } }
    assert_redirected_to mentor
    assert_equal 'Ruby・Railsの設計相談が得意です。', mentor.reload.mentoring_expertise

    patch current_user_path, params: { user: { mentoring_expertise: '' } }
    assert_redirected_to mentor
    assert_empty mentor.reload.mentoring_expertise
  end

  test 'student cannot update mentoring expertise' do
    student = users(:kimura)
    sign_in student
    patch current_user_path, params: { user: { mentoring_expertise: 'Ruby' } }
    assert_nil student.reload.mentoring_expertise
  end

  test "admin can update a mentor's mentoring expertise" do
    mentor = users(:mentormentaro)
    sign_in users(:komagata)
    patch admin_user_path(mentor), params: { user: { mentoring_expertise: 'CSSの相談に対応できます。' } }
    assert_redirected_to mentor
    assert_equal 'CSSの相談に対応できます。', mentor.reload.mentoring_expertise
  end

  test 'mentoring expertise is not exposed on user pages or the users API' do
    mentor = users(:mentormentaro)
    mentor.update!(mentoring_expertise: 'AI連携のためだけの経歴と得意分野')
    sign_in users(:kimura)

    get user_path(mentor)
    assert_response :success
    assert_not_includes response.body, mentor.mentoring_expertise

    get api_user_path(mentor, format: :json)
    assert_response :success
    assert_not_includes response.parsed_body.keys, 'mentoring_expertise'
    assert_not_includes response.body, mentor.mentoring_expertise
  end
end
