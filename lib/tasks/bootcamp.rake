# frozen_string_literal: true

require Rails.root.join('config/environment')
require 'open-uri'
require "google/cloud/storage"

# rubocop:disable Metrics/BlockLength
namespace :bootcamp do
  desc 'Find broken links in practices, pages.'
  task find_broken_link: :environment do
    LinkChecker.new.notify_error_url
  end

  desc 'Migration on production.'
  task migrate: :environment do
    trace = Rake.application.options.trace
    Rake.application.options.trace = true
    case ENV['DB_NAME']
    when 'bootcamp_staging'
      Rake::Task['db:reset'].invoke
    when 'bootcamp_production'
      Rake::Task['db:migrate:with_data'].invoke
    end
    Rake.application.options.trace = trace
  end

  desc 'DB Reset on staging.'
  task reset: :environment do
    Rake::Task['db:reset'].execute if ENV['DB_NAME'] == 'bootcamp_staging'
  end

  desc 'Reset Stripe test DB.'
  task reset_stripe: :environment do
    customer = Stripe::Customer.create(email: 'hatsuno@fjord.jp')
    Subscription.new.create(
      customer.id
    )
  end

  desc 'Disconnect all DB user.'
  task disconnect_all_user: :environment do
    sql = "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'bootcamp_staging' and application_name = 'bin/rails'"
    ActiveRecord::Base.connection.execute sql
  end

  desc 'Validate all users.'
  task validate_all_users: :environment do
    User.order(:id).each do |user|
      next if user.valid?

      puts "Invalid user: #{user.id}, #{user.login_name}"
      puts user.errors.full_messages
    end
  end

  namespace :oneshot do
    desc 'change icons filepath'
    task change_icons_filepath: :environment do
      puts '== START change icons filepath Task =='
      storage = Google::Cloud::Storage.new(
        project_id: 'bootcamp-224405',
        credentials: Base64.decode64(ENV['GOOGLE_CREDENTIALS'].to_s)
      )
      bucket_name = ENV['GCS_BUCKET']
      bucket = storage.bucket bucket_name, skip_lookup: true

      User.find_each do |user|
        if user.avatar.attached?
          url = user.avatar.url
          icon = URI.parse(url).open
          user.avatar.attach(io: icon, filename: user.avatar.filename, key: "icon/#{user.login_name}")
          filename = url.match(%r{#{bucket_name}/([^/]+)})[1]
          file = bucket.file filename
          file.delete
          puts "#{filename} has been renamed to icon/#{user.login_name}"
        end
      end

      puts '== END change icons filepath Task =='
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
