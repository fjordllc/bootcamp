# frozen_string_literal: true

module ProductsHelper
  def unconfirmed_links_label(target)
    case target
    when 'all' then '全ての提出物を一括で開く'
    when 'unchecked', 'unchecked_all' then '未完了の提出物を一括で開く'
    when 'unchecked_no_replied' then '未返信の提出物を一括で開く'
    when 'unassigned' then '未アサインの提出物を一括で開く'
    when 'self_assigned', 'self_assigned_all' then '自分の担当の提出物を一括で開く'
    when 'self_assigned_no_replied' then '未返信の担当の提出物を一括で開く'
    else ''
    end
  end
end
