# frozen_string_literal: true

require "#{Rails.root}/config/environment"

namespace :bootcamp do
  namespace :oneshot do
    desc "Resize works."
    task :resize_all_works do
      Work.order(created_at: :asc).each do |work|
        work.resize_thumbnail! if work.thumbnail.attached?
      end
    end

    desc "Resize images."
    task :resize_all_images do
      User.order(created_at: :asc).each do |user|
        if user.avatar.attached?
          user.resize_avatar!
          puts "resize user #{user.email}"
        end
      end

      Company.order(created_at: :asc).each do |company|
        company.resize_logo! if company.logo.attached?
      end

      Work.order(created_at: :asc).each do |work|
        work.resize_thumbnail! if work.thumbnail.attached?
      end
    end

    desc "insert userid into pages."
    task :insert_userid_into_pages do
      jnchito_id = 676
      komagata_id = 1
      Page.order(created_at: :asc).each do |page|
        case page.id
        when 194, 227, 240
          page.update(user_id: jnchito_id)
        else
          page.update(user_id: komagata_id)
        end
      end
    end
  end
end
