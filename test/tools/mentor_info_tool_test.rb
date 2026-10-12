# frozen_string_literal: true

require 'test_helper'

class MentorInfoToolTest < ActiveSupport::TestCase
  test 'returns active mentors with mentoring expertise and exact mention names' do
    mentor = users(:mentormentaro)
    mentor.update!(mentoring_expertise: 'Rubyが得意です。Webアプリの開発経験があります。')

    result = MentorInfoTool.new.execute

    assert_includes result, "@#{mentor.login_name}"
    assert_includes result, mentor.mentoring_expertise
  end

  test 'excludes students, retired or hibernated mentors and blank profiles' do
    users(:kimura).update!(mentoring_expertise: 'Ruby')
    users(:mentormentaro).update!(mentoring_expertise: 'Ruby', retired_on: Date.current)
    users(:komagata).update!(mentoring_expertise: 'Rails', hibernated_at: Time.current)
    users(:machida).update!(mentoring_expertise: '   ')

    result = MentorInfoTool.new.execute

    %i[kimura mentormentaro komagata machida].each do |name|
      assert_not_includes result, "@#{users(name).login_name}"
    end
  end

  test 'reports when no mentors have mentoring expertise' do
    assert_equal '相談内容に合うメンター情報が登録されていません。メンションせずに回答してください。', MentorInfoTool.new.execute
  end
end
