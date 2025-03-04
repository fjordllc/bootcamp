# frozen_string_literal: true

module PageTabs
  module MentorSurveysHelper
    def mentor_surveys_page_tabs(active_tab:)
      tabs = []
      tabs << { name: 'アンケート', link: mentor_surveys_path }
      tabs << { name: '質問', link: mentor_survey_questions_path }
      render SubTabsComponent.new(tabs:, active_tab:)
    end
  end
end
