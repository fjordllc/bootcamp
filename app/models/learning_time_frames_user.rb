# frozen_string_literal: true

class LearningTimeFramesUser < ApplicationRecord
  belongs_to :user
  belongs_to :learning_time_frame
end
