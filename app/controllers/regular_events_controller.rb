# frozen_string_literal: true

class RegularEventsController < ApplicationController
  before_action :set_regular_event, only: %i[show edit update destroy]

  def index; end

  def show; end

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
      Newspaper.publish(:event_create, @regular_event)
      set_all_users_to_participants if @regular_event.all
      redirect_to @regular_event, notice: notice_message(@regular_event)
    else
      render :new
    end
  end

  def edit; end

  def update
    set_wip
    if @regular_event.update(regular_event_params)
      Newspaper.publish(:regular_event_update, @regular_event)
      set_all_users_to_participants if @regular_event.all
      redirect_to @regular_event, notice: notice_message(@regular_event)
    else
      render :edit
    end
  end

  def destroy
    @regular_event.destroy
    redirect_to regular_events_path, notice: '定期イベントを削除しました。'
  end

  private

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
      user_ids: [],
      regular_event_repeat_rules_attributes: %i[id regular_event_id frequency day_of_the_week _destroy]
    )
  end

  def set_regular_event
    @regular_event = RegularEvent.find(params[:id])
  end

  def set_wip
    @regular_event.wip = (params[:commit] == 'WIP')
  end

  def notice_message(regular_event)
    case params[:action]
    when 'create'
      regular_event.wip? ? '定期イベントをWIPとして保存しました。' : '定期イベントを作成しました。'
    when 'update'
      regular_event.wip? ? '定期イベントをWIPとして保存しました。' : '定期イベントを更新しました。'
    end
  end

  def copy_regular_event(new_event)
    regular_event = RegularEvent.find(params[:id])
    new_event.title = regular_event.title
    new_event.description = regular_event.description
    new_event.finished = regular_event.finished
    new_event.hold_national_holiday = regular_event.hold_national_holiday
    new_event.start_at = regular_event.start_at
    new_event.end_at = regular_event.end_at
    new_event.category = regular_event.category
    new_event.user_ids = regular_event.organizers.map(&:id)

    flash.now[:notice] = '定期イベントをコピーしました。'
  end

  def set_all_users_to_participants
    students_and_trainees_ids = User.students_and_trainees.ids
    create_participants students_and_trainees_ids
    create_watches students_and_trainees_ids
  end

  def create_participants(students_and_trainees_ids)
    new_participants_ids = students_and_trainees_ids - @regular_event.participants.ids
    sql = "INSERT INTO regular_event_participations (user_id, regular_event_id, created_at, updated_at) VALUES #{participants_values(new_participants_ids)};"
    ActiveRecord::Base.connection.execute(sql) unless new_participants_ids.empty?
  end

  def create_watches(students_and_trainees_ids)
    new_watchers_ids = students_and_trainees_ids - @regular_event.watches.pluck(:user_id)
    sql = "INSERT INTO watches (watchable_type, user_id, watchable_id, created_at, updated_at) VALUES #{regular_event_watch_values(new_watchers_ids)};"
    ActiveRecord::Base.connection.execute(sql) unless new_watchers_ids.empty?
  end

  def participants_values(participants_ids)
    time_utc = Time.current.utc
    participants_ids.map { |id| "(#{id}, #{@regular_event.id}, '#{time_utc}', '#{time_utc}')" }.join(',')
  end

  def regular_event_watch_values(watchers_ids)
    time_utc = Time.current.utc
    watchers_ids.map { |id| "('RegularEvent', #{id}, #{@regular_event.id}, '#{time_utc}', '#{time_utc}')" }.join(',')
  end
end
