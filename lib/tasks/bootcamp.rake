# frozen_string_literal: true

require Rails.root.join('config/environment')

# rubocop:disable Metrics/BlockLength
namespace :bootcamp do
  desc 'Find broken links in practices, pages.'
  task find_broken_link: :environment do
    LinkChecker.new.notify_error_url
  end

  desc 'Migration on production.'
  task migrate: :environment do
    name = ENV['DB_NAME'] == 'bootcamp_production' ? 'db:migrate:with_data' : 'db:migrate'
    puts "ENV['DB_NAME']: #{ENV['DB_NAME']}"
    puts "Migration name: #{name}"
    Rake::Task[name].execute
  end

  desc 'DB Reset on staging.'
  task reset: :environment do
    Rake::Task['db:reset'].execute if ENV['DB_NAME'] != 'bootcamp_production'
  end

  namespace :oneshot do
    desc 'Resize works.'
    task resize_all_works: :environment do
      Work.order(created_at: :asc).each do |work|
        work.resize_thumbnail! if work.thumbnail.attached?
      end
    end

    desc 'Resize images.'
    task resize_all_images: :environment do
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

    desc 'Cloud Build Task'
    task cloudbuild: :environment do
      puts '== START Cloud Build Task =='
      puts "#{User.count}件"
      puts '== END   Cloud Build Task =='
    end
  end

  namespace :statistics do
    desc 'save learning minute statistics'
    task save_learning_minute_statistics: :environment do
      Practice.save_learning_minute_statistics
    end
  end
end
# rubocop:enable Metrics/BlockLength
