# frozen_string_literal: true

class MentorInfoTool < RubyLLM::Tool
  description '相談に協力できるメンターのログイン名と得意分野・経験を取得する。'

  def execute
    contexts = User.mentor.unretired.unhibernated.order(:login_name).filter_map do |mentor|
      next if mentor.mentor_ai_context.blank?

      "## @#{mentor.login_name}\n#{mentor.mentor_ai_context}"
    end
    return '相談内容に合うメンター情報が登録されていません。メンションせずに回答してください。' if contexts.empty?

    contexts.join("\n\n")
  end
end
