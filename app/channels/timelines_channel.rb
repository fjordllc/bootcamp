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
      broadcast_to_user_timelines_channel("create_timeline", @timeline)
    else
      broadcast_to_timelines_channel("failed_to_create_timeline", nil)
      broadcast_to_user_timelines_channel("failed_to_create_timeline", nil)
    end
  end

  def update_timeline(data)
    set_host_for_disk_storage
    @timeline = Timeline.find_by(id: data["id"])
    if @timeline.update(permitted(data))
      broadcast_to_timelines_channel("update_timeline", @timeline)
      broadcast_to_user_timelines_channel("update_timeline", @timeline)
    else
      broadcast_to_timelines_channel("failed_to_update_timeline", nil)
      broadcast_to_user_timelines_channel("failed_to_update_timeline", nil)
    end
  end

  def delete_timeline(data)
    set_host_for_disk_storage
    @timeline = Timeline.find_by(id: data["id"])
    if @timeline.destroy
      broadcast_to_timelines_channel("delete_timeline", @timeline)
      broadcast_to_user_timelines_channel("delete_timeline", @timeline)
    else
      broadcast_to_timelines_channel("failed_to_delete_timeline", nil)
      broadcast_to_user_timelines_channel("failed_to_delete_timeline", nil)
    end
  end

  # 引数timelineには分報ページ上の最も古い分報が渡されることが期待される
  def send_past_timelines(timeline)
    set_host_for_disk_storage

    transmit({ event: "send_past_timelines",
              timelines: Timeline
                           .where("created_at <= ?", ajusted_timeline_created_at(Timeline.find(timeline["id"])))
                           .where("id != ?", timeline["id"])
                           .order(created_at: :desc)
                           .limit(20)
                           .map { |timeline| decorated(timeline).format_to_channel }
    })
  end

  private

    def permitted(data)
      params = ActionController::Parameters.new(data)
      params.require(:timeline).permit(:description)
    end

    def broadcast_to_timelines_channel(event, timeline)
      ActionCable.server.broadcast "timelines_channel", { event: event, timeline: decorated(timeline).format_to_channel }
    end

    def broadcast_to_user_timelines_channel(event, timeline)
      ActionCable.server.broadcast "user_#{current_user.id}_timelines_channel", { event: event, timeline: decorated(timeline).format_to_channel }
    end

    def decorated(obj)
      ActiveDecorator::Decorator.instance.decorate(obj)
    end

    def formatted_timelines
      Timeline.order(created_at: :desc).limit(20).map { |timeline| decorated(timeline).format_to_channel }
    end

    # local・test環境でActiveStorage::Current.hostが定義されずユーザーアイコンのservice_urlを取得することができなかったため、以下のように定義
    def set_host_for_disk_storage
      if %i(local test).include? Rails.application.config.active_storage.service
        ActiveStorage::Current.host = Rails.application.config.action_cable.url.gsub(/cable/, "")
      end
    end

    def ajusted_timeline_created_at(timeline)
      # timelines-channel.vueからtimelineのcreated_atを渡しても、"2020-07-10T04:04:33.879+09:00"というようなフォーマットの文字列になっており、
      # それを例えば、Time.parse(timeline["created_at"])としても、
      # usecやsubsecが"879000"となってしまい、小数点第四位から第六位が取得できない。
      # そのままだと、"2020-07-09 19:04:33.879137"のようなPostgreSQLで保存されているフォーマットとのずれが生じる、
      # そのため、Timelineオブジェクトを取り出し、それをTimeオブジェクトに変換をし、調整を加えている。
      # 調整後は"2020-07-09 19:04:33.879137"というPostgreSQLで保存されているフォーマットと同じものになる。

      timeline_created_at = Time.new(timeline.created_at.year,
                                     timeline.created_at.month,
                                     timeline.created_at.day,
                                     timeline.created_at.hour,
                                     timeline.created_at.min,
                                     timeline.created_at.sec
                            ) + timeline.created_at.subsec

      timeline_created_at.in_time_zone("UTC").strftime("%Y-%m-%d %H:%M:%S.%6N")
    end
end
