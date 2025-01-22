# frozen_string_literal: true

module PageTabs
  module CompaniesHelper
    def company_page_tabs(company, active_tab:)
      tabs = []
      tabs << { name: '企業情報', link: company_path(company) }
      tabs << { name: 'ユーザー', link: company_users_path(company) }
      tabs << { name: '日報', link: company_reports_path(company) }
      tabs << { name: '提出物', link: company_products_path(company) }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
