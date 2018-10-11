# frozen_string_literal: true

require "active_record/fixtures"
require "csv"

module SeedHelper
  def import_fixture(name)
    ActiveRecord::Fixtures.create_fixtures(
      "#{Rails.root}/db/fixtures",
      name
    )
  end

  def truncate(name)
    ActiveRecord::Base.connection.execute("TRUNCATE `#{name}`")
  end
end
