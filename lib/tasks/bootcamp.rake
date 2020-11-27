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
      ActiveRecord::Base.transaction do
        reports_sql = <<-SQL
INSERT INTO watches
(watchable_type, watchable_id, user_id, created_at, updated_at)
SELECT 'Report', r.id, r.user_id, now(), now()
FROM reports r
WHERE
NOT EXISTS (
  SELECT *
  FROM watches w
  WHERE
  w.watchable_type = 'Report'
  AND w.watchable_id = r.id
  AND w.user_id = r.user_id
)
SQL
        products_sql = <<-SQL
INSERT INTO watches
(watchable_type, watchable_id, user_id, created_at, updated_at)
SELECT 'Product', p.id, p.user_id, now(), now()
FROM products p
WHERE
NOT EXISTS (
  SELECT *
  FROM watches w
  WHERE
  w.watchable_type = 'Product'
  AND w.watchable_id = p.id
  AND w.user_id = p.user_id
)
SQL
        events_sql = <<-SQL
INSERT INTO watches
(watchable_type, watchable_id, user_id, created_at, updated_at)
SELECT 'Event', e.id, e.user_id, now(), now()
FROM events e
WHERE
NOT EXISTS (
  SELECT *
  FROM watches w
  WHERE
  w.watchable_type = 'Event'
  AND w.watchable_id = e.id
  AND w.user_id = e.user_id
)
SQL
        ActiveRecord::Base.connection.execute(reports_sql)
        ActiveRecord::Base.connection.execute(products_sql)
        ActiveRecord::Base.connection.execute(events_sql)
      end
      puts "== END   Cloud Build Task =="
    end
  end

  namespace :statistics do
    desc "save learning minute statistics"
    task :save_learning_minute_statistics do
      Practice.save_learning_minute_statistics
    end
  end
end
