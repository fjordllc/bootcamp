# frozen_string_literal: true

class MentorController < ApplicationController
  before_action :require_mentor_login
end