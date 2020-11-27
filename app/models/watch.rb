# frozen_string_literal: true

class Watch < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :watchable, polymorphic: true

  def self.migrate_data
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
end
