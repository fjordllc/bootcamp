# frozen_string_literal: true

module StagingEnvironment
  extend ActiveSupport::Concern

  private

  def staging?
    ENV['DB_NAME'] == 'bootcamp_staging'
  end
end
