#!/usr/bin/env rake
# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)

Bootcamp::Application.load_tasks

namespace :check_url do
  task "get_docs_contents" do
    DOCS_CONTENTS = Page.all.map(&:body)
  end

  task "get_practice_contents" do
    PRACTICE_CONTENTS = Practice.all.map(&:description)
    PRACTICE_CONTENTS << Practice.all.map(&:goal)
  end

  task "put_contents_together"  => ["get_docs_contents", "get_practice_contents"] do
    CONTENT_ARRAY = DOCS_CONTENTS << PRACTICE_CONTENTS
    CONTENT_ARRAY.flatten!
  end

  task "get_url" => "put_contents_together" do
    require "uri"
    URL_ARRAY = CONTENT_ARRAY.map { |body| URI.extract(body) }
    URL_ARRAY.flatten!
  end

  task "modify_url" => "get_url" do
    MODIFIED_URL_ARRAY = URL_ARRAY.map do |url|
      if url[-1] == ")"
        url.chop
      else
        url
      end
    end
  end

  task "check_url" => "modify_url" do
    require "net/http"
    ERROR_URL_ARRAY = MODIFIED_URL_ARRAY.map do |url|
      begin
        response = Net::HTTP.get_response(URI.parse(url))
      rescue SocketError
        next url
      end
      url unless response.code == "200" || response.code == "301"
    end
    ERROR_URL_ARRAY.compact!
  end

  task "send_email" => "check_url" do
    unless ERROR_URL_ARRAY.size == 0
      BrokenLinkMailer.notify_error_url(ERROR_URL_ARRAY).deliver_now
    end
  end
end
