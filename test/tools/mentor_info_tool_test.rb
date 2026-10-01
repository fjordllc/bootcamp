# frozen_string_literal: true

require 'test_helper'

class MentorInfoToolTest < ActiveSupport::TestCase
  test 'returns active mentors with AI contexts and exact mention names' do
    mentor = users(:mentormentaro)
    mentor.update!(mentor_ai_context: 'Rubyが得意です。Webアプリの開発経験があります。')

    result = MentorInfoTool.new.execute

    assert_includes result, "@#{mentor.login_name}"
    assert_includes result, mentor.mentor_ai_context
  end

  test 'excludes students, retired or hibernated mentors and blank profiles' do
    users(:kimura).update!(mentor_ai_context: 'Ruby')
    users(:mentormentaro).update!(mentor_ai_context: 'Ruby', retired_on: Date.current)
    users(:komagata).update!(mentor_ai_context: 'Rails', hibernated_at: Time.current)
    users(:machida).update!(mentor_ai_context: '   ')

    result = MentorInfoTool.new.execute

    %i[kimura mentormentaro komagata machida].each do |name|
      assert_not_includes result, "@#{users(name).login_name}"
    end
  end

  test 'reports when no mentors have profiles' do
    assert_equal '相談内容に合うメンター情報が登録されていません。メンションせずに回答してください。', MentorInfoTool.new.execute
  end
end
