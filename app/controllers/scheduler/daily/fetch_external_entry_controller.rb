# frozen_string_literal: true

class Scheduler::Daily::FetchExternalEntryController < ApplicationController
  def show
    ExternalEntry.fetch_and_save_rss_feeds(User.unretired)
    head :ok
  end
end
