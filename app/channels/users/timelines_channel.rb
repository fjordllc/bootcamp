# frozen_string_literal: true

class Users::TimelinesChannel < TimelinesChannel
  def subscribed
    stream_from "user_#{params[:user_id]}_timelines_channel"
    if !subscription_rejected?
      transmit({ event: "subscribe", current_user: decorated(current_user).format_to_channel, timelines: formatted_timelines })
    else
      transmit({ event: "failed_to_subscribe" })
    end
  end

  private
    def formatted_timelines
      Timeline.where(user_id: params[:user_id]).order(created_at: :asc).map { |timeline| decorated(timeline).format_to_channel }
    end
end
