# frozen_string_literal: true

require 'active_delivery/lines/notifier'

class ActivityDelivery < ActiveDelivery::Base
  register_line :activity,
                ActiveDelivery::Lines::Notifier,
                resolver: ->(_) { ActivityNotifier }
  register_line :discord,
                ActiveDelivery::Lines::Notifier,
                resolver: ->(_) { DiscordNotifier }
end
