# frozen_string_literal: true

class EventNoticesController < ApplicationController
  def save_confirmed_event_ids_in_cookies
    event_id = params[:event_id]
    if !cookies[:confirmed_event_ids]
      cookies[:confirmed_event_ids] = { value: JSON.generate([event_id]), expires: 1.month }
    else
      updated_event_ids = JSON.parse(cookies[:confirmed_event_ids]).push(event_id)
      cookies[:confirmed_event_ids] = { value: JSON.generate(updated_event_ids), expires: 1.month }
    end
    redirect_to root_path
  end
end
