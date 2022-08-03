# frozen_string_literal: true

class Scheduler::ValidatorController < SchedulerController
  def show
    output = []

    invalid_users = User.order(:id).reject(&:valid?)
    if invalid_users.empty?
      output << 'Invalidなユーザーはいません。'
    else
      invalid_users.each do |user|
        output << "Invalid user id: #{user.id}, login_name: #{user.login_name}"
        output << user.errors.full_messages
      end
    end

    render plain: output.join("\n")
  end
end
