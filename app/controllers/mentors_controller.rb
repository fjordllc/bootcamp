# frozen_string_literal: true

class MentorsController < ApplicationController
  before_action :require_mentor_login
end
