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

  def send_timelines(oldest_timeline_on_timelines_page)
    set_host_for_disk_storage

    transmit({ event: "send_timelines",
              timelines: Timeline
                           .where("created_at <= ?", ajusted_timeline_created_at(Timeline.find(oldest_timeline_on_timelines_page["id"])))
                           .where("id != ?", oldest_timeline_on_timelines_page["id"])
                           .where(user_id: params[:user_id])
                           .order(created_at: :desc)
                           .limit(20)
                           .map { |timeline| decorated(timeline).format_to_channel }
    })
  end

  private
    def formatted_timelines
      Timeline.where(user_id: params[:user_id]).order(created_at: :desc).limit(20).map { |timeline| decorated(timeline).format_to_channel }
    end
end
