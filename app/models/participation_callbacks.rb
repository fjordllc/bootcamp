# frozen_string_literal: true

class ParticipationCallbacks
  def after_create(participation)
    participation.enable = participation.event.can_participate?
    participation.save
  end
end
