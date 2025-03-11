# frozen_string_literal: true

class RegularEventsController < ApplicationController
  before_action :set_regular_event, only: %i[edit update destroy]

  def index
    @upcoming_events_groups = UpcomingEvent.upcoming_events_groups
  end

  def show
    @regular_event = RegularEvent.find(params[:id])
    Footprint.create_on_resource(@regular_event, current_user) unless @regular_event.user == current_user
    @footprints = Footprint.fetch_for_resource(@regular_event)
    @footprint_total_count = Footprint.count_for_resource(@regular_event)
  end

  def new
    @regular_event = RegularEvent.new
    @regular_event.regular_event_repeat_rules.build

    return unless params[:id]

    copy_regular_event(@regular_event)
  end

  def create
    @regular_event = RegularEvent.new(regular_event_params)
    @regular_event.user = current_user
    set_wip
    if @regular_event.save
      update_published_at
      Organizer.create(user_id: current_user.id, regular_event_id: @regular_event.id)
      Newspaper.publish(:event_create, { event: @regular_event })
      set_all_user_participants_and_watchers
      select_redirect_path
    else
      render :new
    end
  end

  def edit; end

  def update
    set_wip
    if @regular_event.update(regular_event_params)
      update_published_at
      Newspaper.publish(:regular_event_update, { regular_event: @regular_event, sender: current_user })
      set_all_user_participants_and_watchers
      select_redirect_path
    else
      render :edit
    end
  end

  def destroy
    @regular_event.destroy
    redirect_to regular_events_path, notice: '定期イベントを削除しました。'
  end

  private

  def set_regular_event
    @regular_event = current_user.mentor? ? RegularEvent.find(params[:id]) : RegularEvent.organizer_event(current_user).find(params[:id])
  end

  def select_redirect_path
    path = if @regular_event.publish_with_announcement?
             new_announcement_path(regular_event_id: @regular_event.id)
           else
             Redirection.determin_url(self, @regular_event)
           end
    redirect_to path, notice: notice_message(@regular_event)
  end

  def notice_message(regular_event)
    case params[:action]
    when 'create'
      regular_event.wip? ? '定期イベントをWIPとして保存しました。' : '定期イベントを作成しました。'
    when 'update'
      regular_event.wip? ? '定期イベントをWIPとして保存しました。' : '定期イベントを更新しました。'
    end
  end

  def regular_event_params
    params.require(:regular_event).permit(
      :title,
      :description,
      :finished,
      :hold_national_holiday,
      :start_at,
      :end_at,
      :category,
      :all,
      :wants_announcement,
      user_ids: [],
      regular_event_repeat_rules_attributes: %i[id regular_event_id frequency day_of_the_week _destroy]
    )
  end

  def set_wip
    @regular_event.wip = (params[:commit] == 'WIP')
  end

  def update_published_at
    return if @regular_event.wip || @regular_event.published_at?

    @regular_event.update(published_at: Time.current)
  end

  def copy_regular_event(new_event)
    regular_event = RegularEvent.find(params[:id])
    new_event.attributes = regular_event.attributes.slice('title', 'description', 'finished', 'hold_national_holiday', 'start_at', 'end_at', 'category')
    new_event.user_ids = regular_event.organizers.map(&:id)

    flash.now[:notice] = '定期イベントをコピーしました。'
  end

  def set_all_user_participants_and_watchers
    return if @regular_event.wip?

    students_trainees_mentors_and_admins = User.students_trainees_mentors_and_admins.ids
    RegularEvent::ParticipantsCreator.call(regular_event: @regular_event, target: students_trainees_mentors_and_admins)
    RegularEvent::ParticipantsWatcher.call(regular_event: @regular_event, target: students_trainees_mentors_and_admins)
  end
end
