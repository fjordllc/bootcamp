# frozen_string_literal: true

class UpdateEventParticipations
  include Interactor

  def call
    context.event.first_come_participations.each.with_index(1) do |participation, i|
      if i <= context.event.capacity
        participation.update(enable: true)
        context.event.send_notification(participation.user) if participation.waited?
      else
        participation.update(enable: false)
      end
    end
  end
end
