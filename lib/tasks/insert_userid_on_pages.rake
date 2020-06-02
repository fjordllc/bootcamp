# frozen_string_literal: true

namespace :insert_userid_on_pages do
  desc "pagesテーブルにuseridを挿入"
  task insert: :production do
    pages = Page.all
    jnchito_id = 676
    komagata_id = 1

    pages.each do |page|
      case page.id
      when 194, 227, 240
        page.update(user_id: jnchito_id)
      else
        page.update(user_id: komagata_id)
      end
    end
  end
end
