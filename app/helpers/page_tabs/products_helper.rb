# frozen_string_literal: true

module PageTabs
  module ProductsHelper
    def products_page_tabs(active_tab:)
      tabs = []
      tabs << { name: '全て', link: products_path }
      if current_user.admin_or_mentor?
        self_assinged_count = Product.unhibernated_user_products.self_assigned_product(current_user.id).unchecked.size
        self_assinged_badge = Cache.self_assigned_no_replied_product_count(current_user.id)
        tabs << { name: '未完了', link: products_unchecked_index_path, count: Cache.unchecked_product_count }
        tabs << { name: '未アサイン', link: products_unassigned_index_path, badge: Cache.unassigned_product_count }
        tabs << { name: '自分の担当', link: products_self_assigned_index_path, count: self_assinged_count, badge: self_assinged_badge }
      end
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
