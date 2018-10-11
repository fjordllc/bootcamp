# frozen_string_literal: true

class ChangeDefaultSubmissionOfPractices < ActiveRecord::Migration[5.2]
  def change
    change_column_default :practices, :submission, from: true, to: false
  end
end
