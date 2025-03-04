# frozen_string_literal: true

module SubTabs
  module SurveysHelper
    def mentor_surveys_sub_tabs(active_tab:)
      tabs = []
      tabs << { name: 'アンケート', link: mentor_surveys_path }
      tabs << { name: '質問', link: mentor_survey_questions_path }
      render SubTabsComponent.new(tabs:, active_tab:)
    end
  end
end
