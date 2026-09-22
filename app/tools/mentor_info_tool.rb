# frozen_string_literal: true

class MentorInfoTool < RubyLLM::Tool
  description '相談に協力できるメンターのログイン名と得意分野・プロフィールを取得する。'

  def execute
    profiles = User.mentor.unretired.unhibernated.order(:login_name).filter_map do |mentor|
      next if mentor.mentor_profile.blank?

      "## @#{mentor.login_name}\n#{mentor.mentor_profile}"
    end
    return '相談内容に合うメンター情報が登録されていません。メンションせずに回答してください。' if profiles.empty?

    profiles.join("\n\n")
  end
end
