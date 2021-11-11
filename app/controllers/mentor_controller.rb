# frozen_string_literal: true

class MentorController < ApplicationController
  before_action :require_admin_or_mentor_login
end
