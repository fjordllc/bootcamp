# frozen_string_literal: true

module RegularEventHelpers
  extend ActiveSupport::Concern

  private

  def set_regular_event
    @regular_event = RegularEvent.find(params[:id])
  end

  def handle_redirect_after_create_or_update
    path = publish_with_announcement? ? new_announcement_path(regular_event_id: @regular_event.id) : Redirection.determin_url(self, @regular_event)
    redirect_to path, notice: notice_message(@regular_event)
  end

  def publish_with_announcement?
    @regular_event.wants_announcement? && !@regular_event.wip?
  end

  def notice_message(regular_event)
    case params[:action]
    when 'create'
      regular_event.wip? ? '定期イベントをWIPとして保存しました。' : '定期イベントを作成しました。'
    when 'update'
      regular_event.wip? ? '定期イベントをWIPとして保存しました。' : '定期イベントを更新しました。'
    end
  end
end
