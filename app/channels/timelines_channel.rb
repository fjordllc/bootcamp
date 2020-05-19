# frozen_string_literal: true

class TimelinesChannel < ApplicationCable::Channel
  before_subscribe :set_host_for_disk_storage

  def subscribed
    stream_from "timelines_channel"
    if !subscription_rejected?
      transmit({ event: "subscribe", current_user: decorated(current_user).format_to_channel, timelines: formatted_timelines })
    else
      transmit({ event: "failed_to_subscribe" })
    end
  end

  def create_timeline(data)
    # ApplicationCable::Channelにはcontrollerで使えるbefore_actionなどのコールバックが使えないため、set_host_for_disk_storageを呼び出している
    set_host_for_disk_storage
    @timeline = Timeline.new(permitted(data))
    @timeline.user_id = current_user.id
    if @timeline.save
      broadcast_to_timelines_channel("create_timeline", @timeline)
    else
      broadcast_to_timelines_channel("failed_to_create_timeline", nil)
    end
  end

  def update_timeline(data)
    set_host_for_disk_storage
    @timeline = Timeline.find_by(id: data["id"])
    if @timeline.update(permitted(data))
      broadcast_to_timelines_channel("update_timeline", @timeline)
    else
      broadcast_to_timelines_channel("failed_to_update_timeline", nil)
    end
  end

  def delete_timeline(data)
    set_host_for_disk_storage
    @timeline = Timeline.find_by(id: data["id"])
    if @timeline.destroy
      broadcast_to_timelines_channel("delete_timeline", @timeline)
    else
      broadcast_to_timelines_channel("failed_to_delete_timeline", nil)
    end
  end

  private

    def permitted(data)
      params = ActionController::Parameters.new(data)
      params.require(:timeline).permit(:description)
    end

    def broadcast_to_timelines_channel(event, timeline)
      ActionCable.server.broadcast "timelines_channel", { event: event, timeline: decorated(timeline).format_to_channel }
    end

    def decorated(obj)
      ActiveDecorator::Decorator.instance.decorate(obj)
    end

    def formatted_timelines
      Timeline.order(created_at: :asc).map { |timeline| decorated(timeline).format_to_channel }
    end

    # local・test環境でActiveStorage::Current.hostが定義されずユーザーアイコンのservice_urlを取得することができなかったため、以下のように定義
    def set_host_for_disk_storage
      if %i(local test).include? Rails.application.config.active_storage.service
        ActiveStorage::Current.host = Rails.application.config.action_cable.url.gsub(/cable/, "")
      end
    end
end
