# frozen_string_literal: true

require "#{Rails.root}/config/environment"

namespace :bootcamp do
  desc "Find broken links in practices, pages."
  task :find_broken_link do
    LinkChecker.new.notify_error_url
  end

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

    desc "Cloud Build Task"
    task :cloudbuild do
      puts "== START Cloud Build Task =="
      puts "#{User.count}件"
      puts "== END   Cloud Build Task =="
    end
  end

  namespace :statistics do
    desc "save learning minute statistics"
    task :save_learning_minute_statistics do
      practices = Practice.all
      practices.each do |practice|
        practice_id = practice.id
        learning_minute_list = practice.learning_minute_per_user

        if learning_minute_list.sum > 0
          average_learning_minute = practice.average_learning_minute(learning_minute_list)
          median_learning_minute = practice.median_learning_minute(learning_minute_list)
          practice.save_statistic(practice_id, average_learning_minute, median_learning_minute)
        end
      end
    end
  end
end
