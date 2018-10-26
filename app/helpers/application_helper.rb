# frozen_string_literal: true

module ApplicationHelper
  def li_for(record, prefix = nil, options = nil, &block)
    content_tag_for(:li, record, prefix, options, &block)
  end

  def tr_for(record, prefix = nil, options = nil, &block)
    content_tag_for(:tr, record, prefix, options, &block)
  end

  def page_slug
    controller.class.to_s.underscore.
      gsub(%r{/}, "-").
      gsub(/_controller/, "_") + action_name
  end

  def my_practice?(practice)
    return false if current_user.blank?
    [:everyone, current_user.job].include?(practice.target)
  end

  # Slim側でレコード件数を表示する際にページネーションを導入
  # していない画面では page_entries_info が使えないので
  # 差異をラップする
  # kaminari側でいい感じに文言を差し込んでくれる関数
  # https://github.com/fjordllc/bootcamp/issues/551
  #
  # (page_entries_info)があるため、基本的にはそれを利用
  # 差し込む文言はconfig/locales/ja.yml側のhelpers.
  # page_entries_info.more_pages.display_entriesに
  # あるため、変更する場合はそちらを修正する
  #
  # @param [Object] rows        各Modelを引き渡す
  # @param [String] entry_name  オプション
  #                             利用する場合はymlファイルに
  #                             entry_nameを追加すること
  # @return [String]
  #
  # @example
  #   paginate_count(paginated_rows)
  #     # => "100 件（1 〜 25 件を表示）"
  #   paginate_count(not_paginated_rows)
  #     # => "100 件"
  #
  def paginate_count(rows, entry_name = "")
    (rows.respond_to? :total_count) ? page_entries_info(rows, entry_name: entry_name) : "#{rows.count} 件"
  end
end
