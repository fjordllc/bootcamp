# frozen_string_literal: true

require "#{Rails.root}/config/environment"

namespace :bootcamp do
  desc "Find broken links in practices, pages."
  task :find_broken_link do
    LinkChecker.new.notify_error_url
  end

  namespace :oneshot do
    desc "Category data migrate to multiple categories."
    task :migrate_category do
      Practice.order(:category_id, :id).each do |practice|
        category_id = practice.category_id
        practice_id = practice.id
        category_name = practice.category.name
        practice_title = practice.title

        sql = <<-SQL
          INSERT INTO categories_practices (category_id, practice_id) VALUES (#{category_id}, #{practice_id});
        SQL

        puts sql
        puts "INSERT #{category_name},\t#{practice_title}"

        ActiveRecord::Base.connection.execute sql
      end
    end

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

    desc "Cloud Build Task"
    task :cloudbuild do
      puts "== START Cloud Build Task =="
      puts "#{User.count}件"
      puts "== END   Cloud Build Task =="
      Announcement.where(published_at: nil, wip: false).update_all(published_at: Time.current)
    end
  end

  namespace :statistics do
    desc "save learning minute statistics"
    task :save_learning_minute_statistics do
      Practice.save_learning_minute_statistics
    end
  end
end
